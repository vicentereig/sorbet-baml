# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  # Converter for DSPy tools to BAML format
  class DSPyToolConverter
    extend T::Sig

    sig { params(klass: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_dspy_tool(klass, options = {})
      new(options).convert_dspy_tool(klass)
    end

    sig { params(options: T::Hash[Symbol, T.untyped]).void }
    def initialize(options = {})
      @options = options
      @indent_size = T.let(options.fetch(:indent_size, 2), Integer)
      @include_descriptions = T.let(options.fetch(:include_descriptions, true), T::Boolean)
    end

    sig { params(klass: T.untyped).returns(String) }
    def convert_dspy_tool(klass)
      # Extract tool metadata from DSPy tool
      tool_name = klass.tool_name_value || klass.name&.split('::')&.last
      tool_description = klass.tool_description_value

      # Get parameters from DSPy's call_schema_object which extracts from Sorbet signatures.
      call_schema = klass.call_schema_object
      parameters = call_schema[:properties] || {}
      required_params = call_schema[:required] || []

      # Extract Sorbet types directly from the call method signature for richer type info.
      # This gives us access to T::Enum classes, T::Struct references, etc. that are lost
      # when converting to JSON schema.
      sorbet_types = extract_sorbet_types(klass)

      # Collect enum classes referenced by parameters for generating enum definitions.
      enum_classes = collect_enum_classes(sorbet_types)

      lines = []

      # Add tool description as class-level comment if available
      lines << "// #{tool_description}" if @include_descriptions && tool_description

      # Generate enum definitions between description and class
      if enum_classes.any?
        lines << '' unless lines.empty?
        enum_converter = Converter.new(@options)
        enum_classes.each_with_index do |enum_klass, i|
          lines << '' unless i.zero?
          lines << enum_converter.convert_enum(enum_klass)
        end
        lines << ''
      end

      # Generate BAML class definition
      lines << "class #{tool_name} {"

      parameters.each do |param_name, param_info|
        # Use Sorbet type mapping when available (preserves enum/struct type names).
        # Fall back to JSON schema conversion for tools without Sorbet signatures.
        baml_type = if sorbet_types.key?(param_name)
                      TypeMapper.map_type(sorbet_types[param_name])
                    else
                      json_schema_type_to_baml(param_info)
                    end

        # TypeMapper already encodes T.nilable(...) as a trailing `?`.
        # Avoid emitting invalid `??` when DSPy also marks the kwarg optional.
        baml_type += '?' if !required_params.include?(param_name.to_s) && !baml_type.end_with?('?')

        line = "#{' ' * @indent_size}#{param_name} #{baml_type}"

        # Add description from schema if available
        if @include_descriptions && param_info[:description]
          escaped_description = param_info[:description].gsub('"', '\\"')
          line += " @description(\"#{escaped_description}\")"
        end

        lines << line
      end

      lines << '}'
      lines.join("\n")
    end

    private

    # Extract Sorbet types from the tool's call method signature.
    sig { params(klass: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
    def extract_sorbet_types(klass)
      method_obj = klass.instance_method(:call)
      sig_info = T::Utils.signature_for_method(method_obj)
      return {} if sig_info.nil?

      types = {}
      sig_info.arg_types.each { |name, type| types[name] = type }
      sig_info.kwarg_types.each { |name, type| types[name] = type }
      types
    end

    # Collect all T::Enum classes referenced by the given Sorbet types.
    sig { params(sorbet_types: T::Hash[Symbol, T.untyped]).returns(T::Array[T.class_of(T::Enum)]) }
    def collect_enum_classes(sorbet_types)
      enum_classes = T.let([], T::Array[T.class_of(T::Enum)])
      sorbet_types.each_value do |type|
        enum_classes.concat(extract_enum_types(type))
      end
      enum_classes.uniq
    end

    # Recursively extract T::Enum classes from a Sorbet type object.
    sig { params(type: T.untyped).returns(T::Array[T.class_of(T::Enum)]) }
    def extract_enum_types(type)
      case type
      when T::Types::Simple
        raw = type.raw_type
        raw.is_a?(Class) && raw < T::Enum ? [raw] : []
      when T::Types::TypedArray
        extract_enum_types(type.type)
      when T::Types::TypedHash
        extract_enum_types(type.keys) + extract_enum_types(type.values)
      else
        if type.is_a?(Class) && type < T::Enum
          [type]
        elsif type.respond_to?(:types)
          type.types.flat_map { |t| extract_enum_types(t) }
        else
          []
        end
      end
    end

    # Fallback: convert JSON schema type info to BAML type string.
    # Used when Sorbet signature is not available.
    sig { params(json_schema_info: T::Hash[Symbol, T.untyped]).returns(String) }
    def json_schema_type_to_baml(json_schema_info)
      type = json_schema_info[:type]

      # dspy >= 0.34 represents nilable types as ["integer", "null"] rather than just "integer".
      # Extract the primary (non-null) type so the case below matches correctly.
      type = type.reject { |t| t == 'null' }.first if type.is_a?(Array)

      case type
      when :string, 'string'
        'string'
      when :integer, 'integer'
        'int'
      when :number, 'number'
        'float'
      when :boolean, 'boolean'
        'bool'
      when :array, 'array'
        item_type = json_schema_info.dig(:items, :type)
        case item_type
        when :string, 'string' then 'string[]'
        when :integer, 'integer' then 'int[]'
        when :number, 'number' then 'float[]'
        when :boolean, 'boolean' then 'bool[]'
        else 'string[]' # fallback
        end
      when :object, 'object'
        # For object types, we'll default to a map<string, string>
        # In a more sophisticated implementation, we'd handle nested objects
        'map<string, string>'
      else
        'string' # fallback for unknown types
      end
    end
  end
end

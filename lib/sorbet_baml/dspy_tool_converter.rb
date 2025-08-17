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

      # Get parameters from DSPy's call_schema which extracts from Sorbet signatures
      call_schema = klass.call_schema
      parameters = call_schema[:properties] || {}
      required_params = call_schema[:required] || []

      lines = []

      # Add tool description as class-level comment if available
      lines << "// #{tool_description}" if @include_descriptions && tool_description

      # Generate BAML class definition
      lines << "class #{tool_name} {"

      parameters.each do |param_name, param_info|
        # Convert JSON schema type to BAML type
        baml_type = json_schema_type_to_baml(param_info)

        # Add optional marker if parameter is not required
        baml_type += '?' unless required_params.include?(param_name.to_s)

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

    sig { params(json_schema_info: T::Hash[Symbol, T.untyped]).returns(String) }
    def json_schema_type_to_baml(json_schema_info)
      type = json_schema_info[:type]

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

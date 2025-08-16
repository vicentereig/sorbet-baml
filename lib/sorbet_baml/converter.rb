# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "set"
require_relative "comment_extractor"

module SorbetBaml
  # Main converter class for transforming Sorbet types to BAML
  class Converter
    extend T::Sig

    sig { params(klass: T.class_of(T::Struct), options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_struct(klass, options = {})
      new(options).convert_struct(klass)
    end

    sig { params(klasses: T::Array[T.class_of(T::Struct)], options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_structs(klasses, options = {})
      converter = new(options)
      
      if converter.instance_variable_get(:@include_dependencies)
        # When dependencies are enabled, collect all unique dependencies and convert once
        all_dependencies = Set.new
        enum_dependencies = Set.new
        
        klasses.each do |klass|
          deps = DependencyResolver.resolve_dependencies(klass)
          all_dependencies.merge(deps)
          enum_deps = converter.send(:find_enum_dependencies, deps)
          enum_dependencies.merge(enum_deps)
        end
        
        # Convert all unique types
        converted_types = []
        enum_dependencies.each { |enum_klass| converted_types << converter.convert_enum(enum_klass) }
        all_dependencies.each { |struct_klass| converted_types << converter.send(:convert_single_struct, struct_klass) }
        
        converted_types.join("\n\n")
      else
        # When dependencies are disabled, convert each struct individually
        klasses.map { |klass| converter.send(:convert_single_struct, klass) }.join("\n\n")
      end
    end

    sig { params(klass: T.class_of(T::Enum), options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_enum(klass, options = {})
      new(options).convert_enum(klass)
    end

    sig { params(options: T::Hash[Symbol, T.untyped]).void }
    def initialize(options = {})
      @options = options
      @indent_size = T.let(options.fetch(:indent_size, 2), Integer)
      @include_descriptions = T.let(options.fetch(:include_descriptions, true), T::Boolean)
      @include_dependencies = T.let(options.fetch(:include_dependencies, true), T::Boolean)
    end

    sig { params(klass: T.class_of(T::Struct)).returns(String) }
    def convert_struct(klass)
      if @include_dependencies
        # Get all dependencies in correct order and convert them all
        dependencies = DependencyResolver.resolve_dependencies(klass)
        
        # Also find all enum dependencies
        enum_dependencies = find_enum_dependencies(dependencies)
        
        # Convert enums first, then structs
        converted_types = []
        enum_dependencies.each { |enum_klass| converted_types << convert_enum(enum_klass) }
        dependencies.each { |dep_klass| converted_types << convert_single_struct(dep_klass) }
        
        converted_types.join("\n\n")
      else
        # Just convert the single struct
        convert_single_struct(klass)
      end
    end

    sig { params(klass: T.class_of(T::Enum)).returns(String) }
    def convert_enum(klass)
      class_name = klass.name || klass.to_s
      simple_name = class_name.split('::').last
      lines = ["enum #{simple_name} {"]
      
      # Extract comments if requested
      comments = @include_descriptions ? CommentExtractor.extract_enum_comments(klass) : {}
      
      # Get all enum values by calling values method
      enum_values = klass.values
      enum_values.each do |enum_instance|
        value = enum_instance.serialize
        
        # Find the constant name for this value
        constant_name = T.let(nil, T.nilable(String))
        klass.constants.each do |const_name|
          const_value = klass.const_get(const_name)
          if const_value.is_a?(klass) && const_value.serialize == value
            constant_name = const_name.to_s
            break
          end
        end
        
        line = "#{' ' * @indent_size}\"#{value}\""
        
        # Add description if available (BAML uses @description annotations, not comments)
        if @include_descriptions && constant_name && comments[constant_name]
          line += " @description(\"#{T.must(comments[constant_name]).gsub('"', '\\"')}\")"
        end
        
        lines << line
      end
      
      lines << "}"
      lines.join("\n")
    end

    private

    sig { params(klass: T.class_of(T::Struct)).returns(String) }
    def convert_single_struct(klass)
      props = klass.props
      
      class_name = klass.name || klass.to_s
      simple_name = class_name.split('::').last
      lines = ["class #{simple_name} {"]
      
      # Extract comments if requested
      comments = @include_descriptions ? CommentExtractor.extract_field_comments(klass) : {}
      
      props.each do |name, prop_info|
        baml_type = TypeMapper.map_type(prop_info[:type_object])
        line = "#{' ' * @indent_size}#{name} #{baml_type}"
        
        # Add description if available (BAML uses @description annotations)
        if @include_descriptions && comments[name.to_s]
          escaped_comment = T.must(comments[name.to_s]).gsub('"', '\\"')
          line += " @description(\"#{escaped_comment}\")"
        end
        
        lines << line
      end
      
      lines << "}"
      lines.join("\n")
    end
    
    sig { params(struct_classes: T::Array[T.class_of(T::Struct)]).returns(T::Array[T.class_of(T::Enum)]) }
    def find_enum_dependencies(struct_classes)
      enum_deps = Set.new
      
      struct_classes.each do |struct_klass|
        struct_klass.props.each do |_name, prop_info|
          type_object = prop_info[:type_object]
          enum_deps.merge(extract_enum_types(type_object))
        end
      end
      
      enum_deps.to_a
    end
    
    sig { params(type_object: T.untyped).returns(T::Array[T.class_of(T::Enum)]) }
    def extract_enum_types(type_object)
      return [] if type_object.nil?
      
      case type_object
      when T::Types::Simple
        extract_enum_from_simple_type(type_object.raw_type)
      when T::Types::TypedArray
        extract_enum_types(type_object.type)
      when T::Types::TypedHash
        # Check both key and value types
        key_types = extract_enum_types(type_object.keys)
        value_types = extract_enum_types(type_object.values)
        key_types + value_types
      else
        # Check if it's a union type
        if type_object.respond_to?(:types)
          type_object.types.flat_map { |t| extract_enum_types(t) }
        else
          []
        end
      end
    end
    
    sig { params(raw_type: T.untyped).returns(T::Array[T.class_of(T::Enum)]) }
    def extract_enum_from_simple_type(raw_type)
      # Check if this raw_type is a T::Enum subclass
      if raw_type.is_a?(Class) && raw_type < T::Enum
        [raw_type]
      else
        []
      end
    end
  end
end
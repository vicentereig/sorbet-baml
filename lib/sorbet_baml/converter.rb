# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

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
      klasses.map { |klass| converter.convert_struct(klass) }.join("\n\n")
    end

    sig { params(klass: T.class_of(T::Enum), options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_enum(klass, options = {})
      new(options).convert_enum(klass)
    end

    sig { params(options: T::Hash[Symbol, T.untyped]).void }
    def initialize(options = {})
      @options = options
      @indent_size = T.let(options.fetch(:indent_size, 2), Integer)
      @include_descriptions = T.let(options.fetch(:include_descriptions, false), T::Boolean)
      @include_dependencies = T.let(options.fetch(:include_dependencies, false), T::Boolean)
    end

    sig { params(klass: T.class_of(T::Struct)).returns(String) }
    def convert_struct(klass)
      if @include_dependencies
        # Get all dependencies in correct order and convert them all
        dependencies = DependencyResolver.resolve_dependencies(klass)
        dependencies.map { |dep_klass| convert_single_struct(dep_klass) }.join("\n\n")
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
      
      # Get all enum values by calling values method
      enum_values = klass.values
      enum_values.each do |enum_instance|
        value = enum_instance.serialize
        lines << "#{' ' * @indent_size}\"#{value}\""
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
      
      props.each do |name, prop_info|
        baml_type = TypeMapper.map_type(prop_info[:type_object])
        lines << "#{' ' * @indent_size}#{name} #{baml_type}"
      end
      
      lines << "}"
      lines.join("\n")
    end
  end
end
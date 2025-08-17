# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  # Resolves dependencies between T::Struct types and orders them topologically
  class DependencyResolver
    extend T::Sig

    sig { params(klass: T.class_of(T::Struct)).returns(T::Array[T.class_of(T::Struct)]) }
    def self.resolve_dependencies(klass)
      new.resolve_dependencies(klass)
    end

    sig { void }
    def initialize
      @visited = T.let(Set.new, T::Set[T.class_of(T::Struct)])
      @dependencies = T.let([], T::Array[T.class_of(T::Struct)])
    end

    sig { params(klass: T.class_of(T::Struct)).returns(T::Array[T.class_of(T::Struct)]) }
    def resolve_dependencies(klass)
      @visited.clear
      @dependencies.clear

      # Perform depth-first search to find all dependencies
      visit(klass)

      # Dependencies are already in correct topological order
      # (dependencies first, then the types that depend on them)
      @dependencies
    end

    private

    sig { params(klass: T.class_of(T::Struct)).void }
    def visit(klass)
      return if @visited.include?(klass)

      @visited.add(klass)

      # Find all T::Struct dependencies in this class
      struct_dependencies = find_struct_dependencies(klass)

      # Visit dependencies first (depth-first)
      struct_dependencies.each { |dep| visit(dep) }

      # Add this class after its dependencies
      @dependencies << klass
    end

    sig { params(klass: T.class_of(T::Struct)).returns(T::Array[T.class_of(T::Struct)]) }
    def find_struct_dependencies(klass)
      dependencies = []

      klass.props.each do |_name, prop_info|
        type_object = prop_info[:type_object]
        dependencies.concat(extract_struct_types(type_object))
      end

      dependencies.uniq
    end

    sig { params(type_object: T.untyped).returns(T::Array[T.class_of(T::Struct)]) }
    def extract_struct_types(type_object)
      return [] if type_object.nil?

      case type_object
      when T::Types::Simple
        extract_from_simple_type(type_object.raw_type)
      when T::Types::TypedArray
        extract_struct_types(type_object.type)
      when T::Types::TypedHash
        # Check both key and value types
        key_types = extract_struct_types(type_object.keys)
        value_types = extract_struct_types(type_object.values)
        key_types + value_types
      else
        # Check if it's a union type
        if type_object.respond_to?(:types)
          type_object.types.flat_map { |t| extract_struct_types(t) }
        else
          []
        end
      end
    end

    sig { params(raw_type: T.untyped).returns(T::Array[T.class_of(T::Struct)]) }
    def extract_from_simple_type(raw_type)
      # Check if this raw_type is a T::Struct subclass
      if raw_type.is_a?(Class) && raw_type < T::Struct
        [raw_type]
      else
        []
      end
    end
  end
end

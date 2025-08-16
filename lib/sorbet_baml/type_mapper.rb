# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  # Maps Sorbet type objects to BAML type strings
  class TypeMapper
    extend T::Sig

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_type(type_object)
      return "string" if type_object.nil?
      
      case type_object
      when T::Types::Simple
        map_simple_type(type_object.raw_type)
      when T::Types::TypedArray
        map_array_type(type_object)
      else
        # Check if it's a union type (T.nilable)
        if type_object.respond_to?(:types)
          map_nilable_type(type_object)
        else
          # Fallback for unknown types
          "unknown"
        end
      end
    end

    sig { params(raw_type: T.untyped).returns(String) }
    def self.map_simple_type(raw_type)
      case raw_type.name
      when "String"
        "string"
      when "Integer"
        "int"
      when "Float"
        "float"
      when "TrueClass", "FalseClass"
        "bool"
      when "NilClass"
        "null"
      when "Symbol"
        "string"
      when "Date", "DateTime", "Time"
        "string"
      else
        # Check if it's a T::Struct
        if raw_type < T::Struct
          type_name = raw_type.name || raw_type.to_s
          type_name.split('::').last || "unknown"
        else
          "unknown"
        end
      end
    end

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_nilable_type(type_object)
      # Extract the non-nil type from the union
      types = type_object.types
      non_nil_type = types.find { |t| t.raw_type != NilClass }
      
      if non_nil_type
        base_type = map_type(non_nil_type)
        "#{base_type}?"
      else
        "null"
      end
    end

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_array_type(type_object)
      element_type = map_type(type_object.type)
      "#{element_type}[]"
    end
  end
end
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
      when T::Types::TypedHash
        map_hash_type(type_object)
      else
        # Check if it's a union type (T.nilable or T.any)
        if type_object.respond_to?(:types)
          map_union_type(type_object)
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
        # Check if it's a T::Struct or T::Enum
        if raw_type < T::Struct || raw_type < T::Enum
          type_name = raw_type.name || raw_type.to_s
          type_name.split('::').last || "unknown"
        else
          "unknown"
        end
      end
    end

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_union_type(type_object)
      types = type_object.types
      nil_type = types.find { |t| t.raw_type == NilClass }
      non_nil_types = types.reject { |t| t.raw_type == NilClass }
      
      if non_nil_types.empty?
        return "null"
      end
      
      if non_nil_types.size == 1
        # This is T.nilable(T) - single type with nil
        base_type = map_type(non_nil_types.first)
        return nil_type ? "#{base_type}?" : base_type
      end
      
      # This is T.any with multiple types
      mapped_types = non_nil_types.map { |t| map_type(t) }
      
      # Special case: TrueClass + FalseClass = bool
      if mapped_types.sort == ["bool", "bool"]
        union_string = "bool"
      else
        # Remove duplicates and join
        union_string = mapped_types.uniq.join(" | ")
      end
      
      # If nil is present, wrap in parentheses and add ?
      if nil_type
        "(#{union_string})?"
      else
        union_string
      end
    end

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_array_type(type_object)
      element_type = map_type(type_object.type)
      
      # If element type contains union (|), wrap in parentheses for correct precedence
      if element_type.include?("|")
        "(#{element_type})[]"
      else
        "#{element_type}[]"
      end
    end

    sig { params(type_object: T.untyped).returns(String) }
    def self.map_hash_type(type_object)
      # T::Types::TypedHash has keys and values methods
      key_type = map_type(type_object.keys)
      value_type = map_type(type_object.values)
      "map<#{key_type}, #{value_type}>"
    end
  end
end
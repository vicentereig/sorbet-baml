# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  module TestFixtures
    # Test struct with hash types
    class UserPreferences < T::Struct
      const :settings, T::Hash[String, String]
      const :metadata, T::Hash[Symbol, T.any(String, Integer)]
      const :tags, T::Hash[String, T::Array[String]]
    end

    # Test struct with union types
    class FlexibleData < T::Struct
      const :value, T.any(String, Integer, Float)
      const :optional_union, T.nilable(T.any(String, Integer))
      const :status, T.any(String, T::Boolean)
    end

    # Test struct combining different advanced types
    class ComplexStruct < T::Struct
      const :id, T.any(String, Integer)
      const :config, T::Hash[String, T.any(String, Integer, T::Boolean)]
      const :labels, T::Hash[String, T::Array[String]]
      const :mixed_array, T::Array[T.any(String, Integer)]
    end

    # Test struct with T.untyped fields (dynamic values)
    # Common in tool schemas and execution contexts
    class DynamicStruct < T::Struct
      const :name, String
      const :data, T.untyped
      const :metadata, T::Hash[Symbol, T.untyped]
    end

    # Test struct with T.nilable hash containing T.untyped values
    # This is the exact pattern that caused issue #192 in DSPy.rb
    class ToolSchemaStruct < T::Struct
      const :tool_name, String
      const :description, String
      const :schema, T::Hash[Symbol, T.untyped]
    end

    # Test struct with nilable hash of untyped (common in LLM tool definitions)
    class OptionalDynamicStruct < T::Struct
      const :id, String
      const :optional_config, T.nilable(T::Hash[String, T.untyped])
    end

    # Test union containing TypedHash (triggers the raw_type bug)
    class UnionWithHashStruct < T::Struct
      const :value, T.any(String, T::Hash[Symbol, Integer])
    end
  end
end

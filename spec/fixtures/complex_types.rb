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
  end
end

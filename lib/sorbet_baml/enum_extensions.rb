# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  # Extensions to add BAML conversion methods to T::Enum
  module EnumExtensions
    extend T::Sig

    # Convert this enum to BAML type definition
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def to_baml(options = {})
      baml_type_definition(options)
    end

    # Convert this enum to BAML type definition with options
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def baml_type_definition(options = {})
      SorbetBaml::Converter.from_enum(T.cast(self, T.class_of(T::Enum)), options)
    end
  end
end
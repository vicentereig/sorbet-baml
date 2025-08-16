# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  # Extensions to add BAML conversion methods to T::Struct
  module StructExtensions
    extend T::Sig

    # Convert this struct to BAML type definition
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def to_baml(options = {})
      baml_type_definition(options)
    end

    # Convert this struct to BAML type definition with options
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def baml_type_definition(options = {})
      SorbetBaml::Converter.from_struct(T.cast(self, T.class_of(T::Struct)), options)
    end
  end
end
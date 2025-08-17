# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  # Extensions to add BAML tool conversion methods to T::Struct
  module ToolExtensions
    extend T::Sig

    # Convert this struct to BAML tool definition
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def to_baml_tool(options = {})
      baml_tool_definition(options)
    end

    # Convert this struct to BAML tool definition with options
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def baml_tool_definition(options = {})
      SorbetBaml::Converter.from_tool(T.cast(self, T.class_of(T::Struct)), options)
    end
  end
end

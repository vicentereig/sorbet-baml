# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  # Extensions to add BAML conversion methods to DSPy::Tools::Base
  module DSPyToolExtensions
    extend T::Sig

    # Convert this DSPy tool to BAML tool definition
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def to_baml(options = {})
      baml_tool_definition(options)
    end

    # Convert this DSPy tool to BAML tool definition with options
    sig { params(options: T::Hash[Symbol, T.untyped]).returns(String) }
    def baml_tool_definition(options = {})
      SorbetBaml::DSPyToolConverter.from_dspy_tool(T.cast(self, T.class_of(DSPy::Tools::Base)), options)
    end
  end
end

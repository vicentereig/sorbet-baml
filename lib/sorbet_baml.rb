# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative 'sorbet_baml/version'
require_relative 'sorbet_baml/converter'
require_relative 'sorbet_baml/type_mapper'
require_relative 'sorbet_baml/dependency_resolver'
require_relative 'sorbet_baml/comment_extractor'
require_relative 'sorbet_baml/description_extractor'
require_relative 'sorbet_baml/description_extension'
require_relative 'sorbet_baml/struct_extensions'
require_relative 'sorbet_baml/enum_extensions'
require_relative 'sorbet_baml/tool_extensions'

# Optional DSPy support
begin
  require 'dspy'
  require_relative 'sorbet_baml/dspy_tool_converter'
  require_relative 'sorbet_baml/dspy_tool_extensions'
rescue LoadError
  # DSPy not available, skip DSPy tool support
end

module SorbetBaml
  class Error < StandardError; end

  extend T::Sig

  # Convert a single T::Struct to BAML definition
  sig { params(klass: T.class_of(T::Struct), options: T::Hash[Symbol, T.untyped]).returns(String) }
  def self.from_struct(klass, options = {})
    Converter.from_struct(klass, options)
  end

  # Convert multiple T::Structs to BAML definitions
  sig { params(klasses: T::Array[T.class_of(T::Struct)], options: T::Hash[Symbol, T.untyped]).returns(String) }
  def self.from_structs(klasses, options = {})
    Converter.from_structs(klasses, options)
  end

  # Convert a single T::Struct to BAML tool definition
  sig { params(klass: T.class_of(T::Struct), options: T::Hash[Symbol, T.untyped]).returns(String) }
  def self.from_tool(klass, options = {})
    Converter.from_tool(klass, options)
  end

  # Convert a DSPy tool to BAML tool definition (only if DSPy is available)
  if defined?(DSPy::Tools::Base)
    sig { params(klass: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(String) }
    def self.from_dspy_tool(klass, options = {})
      DSPyToolConverter.from_dspy_tool(klass, options)
    end
  end
end

# Extend T::Struct and T::Enum with BAML conversion methods
T::Struct.extend(SorbetBaml::StructExtensions)
T::Struct.extend(SorbetBaml::ToolExtensions)
T::Enum.extend(SorbetBaml::EnumExtensions)

# Extend DSPy::Tools::Base with BAML conversion methods if DSPy is available
if defined?(DSPy::Tools::Base)
  T.unsafe(eval('DSPy::Tools::Base')).extend(SorbetBaml::DSPyToolExtensions)
end

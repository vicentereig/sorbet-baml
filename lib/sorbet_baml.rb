# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "sorbet_baml/version"
require_relative "sorbet_baml/converter"
require_relative "sorbet_baml/type_mapper"
require_relative "sorbet_baml/struct_extensions"

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
end

# Extend T::Struct with BAML conversion methods
T::Struct.extend(SorbetBaml::StructExtensions)

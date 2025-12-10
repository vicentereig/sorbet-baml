# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'sorbet-runtime'
require_relative '../fixtures/complex_types'

RSpec.describe 'Advanced Type Support' do
  describe 'T::Hash types' do
    it 'converts simple hash types to map syntax' do
      result = SorbetBaml::TestFixtures::UserPreferences.to_baml

      expect(result).to eq(<<~BAML.strip)
        class UserPreferences {
          settings map<string, string>
          metadata map<string, string | int>
          tags map<string, string[]>
        }
      BAML
    end
  end

  describe 'T.any (union) types' do
    it 'converts union types to pipe syntax' do
      result = SorbetBaml::TestFixtures::FlexibleData.to_baml

      expect(result).to eq(<<~BAML.strip)
        class FlexibleData {
          value string | int | float
          optional_union (string | int)?
          status string | bool
        }
      BAML
    end
  end

  describe 'Complex combined types' do
    it 'handles multiple advanced type features together' do
      result = SorbetBaml::TestFixtures::ComplexStruct.to_baml

      expect(result).to eq(<<~BAML.strip)
        class ComplexStruct {
          id string | int
          config map<string, string | int | bool>
          labels map<string, string[]>
          mixed_array (string | int)[]
        }
      BAML
    end
  end

  describe 'Edge cases' do
    it 'handles nested hash types' do
      # Test that we can handle hash with complex value types
      result = SorbetBaml::TestFixtures::UserPreferences.to_baml
      expect(result).to include('map<string, string[]>')
    end

    it 'handles union with nil properly' do
      result = SorbetBaml::TestFixtures::FlexibleData.to_baml
      expect(result).to include('(string | int)?')
    end
  end

  describe 'T.untyped handling' do
    it 'converts T.untyped fields to json type' do
      result = SorbetBaml::TestFixtures::DynamicStruct.to_baml

      expect(result).to eq(<<~BAML.strip)
        class DynamicStruct {
          name string
          data json
          metadata map<string, json>
        }
      BAML
    end

    it 'converts hash with T.untyped values (tool schema pattern)' do
      result = SorbetBaml::TestFixtures::ToolSchemaStruct.to_baml

      expect(result).to eq(<<~BAML.strip)
        class ToolSchemaStruct {
          tool_name string
          description string
          schema map<string, json>
        }
      BAML
    end

    it 'converts T.nilable(T::Hash[String, T.untyped]) without error' do
      result = SorbetBaml::TestFixtures::OptionalDynamicStruct.to_baml

      expect(result).to eq(<<~BAML.strip)
        class OptionalDynamicStruct {
          id string
          optional_config map<string, json>?
        }
      BAML
    end
  end

  describe 'Union types containing TypedHash' do
    it 'handles T.any with TypedHash without calling raw_type on it' do
      # This was the bug in issue #192 - map_union_type called raw_type on TypedHash
      result = SorbetBaml::TestFixtures::UnionWithHashStruct.to_baml

      expect(result).to eq(<<~BAML.strip)
        class UnionWithHashStruct {
          value string | map<string, int>
        }
      BAML
    end
  end

  describe 'TypeMapper edge cases' do
    it 'maps bare T.untyped to json' do
      type = T.untyped
      result = SorbetBaml::TypeMapper.map_type(type)
      expect(result).to eq('json')
    end

    it 'maps T::Hash with untyped values correctly' do
      type = T::Hash[Symbol, T.untyped]
      result = SorbetBaml::TypeMapper.map_type(type)
      expect(result).to eq('map<string, json>')
    end

    it 'handles nilable hash with untyped values' do
      type = T.nilable(T::Hash[String, T.untyped])
      result = SorbetBaml::TypeMapper.map_type(type)
      expect(result).to eq('map<string, json>?')
    end

    it 'handles union containing TypedHash without error' do
      type = T.any(String, T::Hash[Symbol, Integer])
      result = SorbetBaml::TypeMapper.map_type(type)
      expect(result).to eq('string | map<string, int>')
    end
  end
end

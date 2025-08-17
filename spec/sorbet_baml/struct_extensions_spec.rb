# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'sorbet-runtime'
require_relative '../fixtures/test_structs'

RSpec.describe 'T::Struct Extensions' do
  describe '.to_baml' do
    it 'responds to to_baml method' do
      expect(SorbetBaml::TestFixtures::SimpleUser).to respond_to(:to_baml)
    end

    it 'converts simple struct to BAML format' do
      result = SorbetBaml::TestFixtures::SimpleUser.to_baml

      expect(result).to eq(<<~BAML.strip)
        class SimpleUser {
          name string
          age int
        }
      BAML
    end

    it 'converts struct with optional fields' do
      result = SorbetBaml::TestFixtures::UserWithOptionals.to_baml

      expect(result).to eq(<<~BAML.strip)
        class UserWithOptionals {
          name string
          email string?
          age int?
        }
      BAML
    end

    it 'converts struct with arrays' do
      result = SorbetBaml::TestFixtures::UserWithArrays.to_baml

      expect(result).to eq(<<~BAML.strip)
        class UserWithArrays {
          tags string[]
          scores int[]
        }
      BAML
    end
  end

  describe '.baml_type_definition' do
    it 'responds to baml_type_definition method' do
      expect(SorbetBaml::TestFixtures::SimpleUser).to respond_to(:baml_type_definition)
    end

    it 'accepts options hash' do
      expect { SorbetBaml::TestFixtures::SimpleUser.baml_type_definition(indent_size: 4) }.not_to raise_error
    end

    it 'respects indent_size option' do
      result = SorbetBaml::TestFixtures::SimpleUser.baml_type_definition(indent_size: 4)

      expect(result).to eq(<<~BAML.strip)
        class SimpleUser {
            name string
            age int
        }
      BAML
    end

    it 'behaves the same as to_baml when no options provided' do
      struct = SorbetBaml::TestFixtures::SimpleUser
      expect(struct.to_baml).to eq(struct.baml_type_definition)
    end
  end
end

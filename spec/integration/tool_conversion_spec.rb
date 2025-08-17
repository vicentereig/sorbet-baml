# typed: strict
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../fixtures/test_tools'

require_relative '../fixtures/test_dspy_tools' if defined?(DSPy::Tools::Base)

RSpec.describe 'Tool Conversion Integration' do
  describe 'T::Struct-based tools' do
    it 'converts simple tools through module API' do
      baml = SorbetBaml.from_tool(SorbetBaml::TestFixtures::ReplyTool)

      expect(baml).to eq(<<~BAML.chomp)
        class ReplyTool {
          response string
        }
      BAML
    end

    it 'converts tools with extension method' do
      baml = SorbetBaml::TestFixtures::ReplyTool.to_baml_tool

      expect(baml).to eq(<<~BAML.chomp)
        class ReplyTool {
          response string
        }
      BAML
    end

    it 'handles complex tool types' do
      baml = SorbetBaml::TestFixtures::UserCreateTool.to_baml_tool

      expect(baml).to include('map<string, string>')
      expect(baml).to include('string[]')
    end
  end

  if defined?(DSPy::Tools::Base)
    describe 'DSPy-based tools' do
      it 'converts DSPy tools through module API' do
        baml = SorbetBaml.from_dspy_tool(SorbetBaml::TestFixtures::CalculatorTool)

        expect(baml).to include('class calculator {')
        expect(baml).to include('operation string')
        expect(baml).to include('num1 float')
        expect(baml).to include('num2 float')
      end

      it 'converts DSPy tools with extension method' do
        baml = SorbetBaml::TestFixtures::CalculatorTool.to_baml

        expect(baml).to include('class calculator {')
        expect(baml).to include('// Performs basic arithmetic operations')
      end

      it 'handles optional parameters correctly' do
        baml = SorbetBaml::TestFixtures::DSPySearchTool.to_baml

        expect(baml).to include('query string')
        expect(baml).to include('limit int?')
      end
    end
  end

  describe 'Error handling' do
    it 'handles tools without names gracefully' do
      anonymous_tool_class = Class.new(T::Struct) do
        const :message, String
      end

      expect do
        SorbetBaml.from_tool(anonymous_tool_class)
      end.not_to raise_error
    end
  end
end

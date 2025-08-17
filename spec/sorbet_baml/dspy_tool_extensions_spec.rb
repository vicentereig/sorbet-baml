# typed: strict
# frozen_string_literal: true

require_relative '../spec_helper'

if defined?(DSPy::Tools::Base)
  require_relative '../fixtures/test_dspy_tools'

  RSpec.describe SorbetBaml::DSPyToolExtensions do
    describe 'to_baml' do
      it 'converts DSPy tool with tool_name and tool_description to BAML' do
        baml = SorbetBaml::TestFixtures::CalculatorTool.to_baml

        expect(baml).to include('class calculator {')
        expect(baml).to include('// Performs basic arithmetic operations')
      end

      it 'converts DSPy tool with parameters to BAML' do
        baml = SorbetBaml::TestFixtures::DSPySearchTool.to_baml

        expect(baml).to include('class search {')
        expect(baml).to include('// Search for information')
      end

      it 'disables descriptions when requested' do
        baml = SorbetBaml::TestFixtures::CalculatorTool.to_baml(include_descriptions: false)

        expect(baml).to include('class calculator {')
        expect(baml).not_to include('// Performs basic arithmetic operations')
      end

      it 'supports custom indentation' do
        baml = SorbetBaml::TestFixtures::CalculatorTool.to_baml(indent_size: 4)

        lines = baml.split("\n")
        # Find a parameter line (contains both a parameter name and a type)
        param_line = lines.find { |line| line.match(/^\s+\w+\s+(string|int|float|bool)/) }
        expect(param_line).to start_with('    ') if param_line
      end
    end

    describe 'baml_tool_definition' do
      it 'is an alias for to_baml' do
        tool_def = SorbetBaml::TestFixtures::CalculatorTool.baml_tool_definition
        to_baml = SorbetBaml::TestFixtures::CalculatorTool.to_baml

        expect(tool_def).to eq(to_baml)
      end
    end
  end
else
  RSpec.describe 'DSPy not available' do
    it 'skips DSPy tool tests when DSPy is not available' do
      expect(true).to eq(true) # This test just documents that DSPy is not available
    end
  end
end

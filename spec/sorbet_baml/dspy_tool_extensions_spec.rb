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

    describe 'enum parameter support' do
      it 'generates enum definition and uses enum type for array of enums' do
        baml = SorbetBaml::TestFixtures::EnumSearchTool.to_baml

        expect(baml).to include('enum SearchCategory {')
        expect(baml).to include('"web"')
        expect(baml).to include('"images"')
        expect(baml).to include('"news"')
        expect(baml).to include('"videos"')
        expect(baml).to include('categories SearchCategory[]')
        expect(baml).to include('class enum_search {')
      end

      it 'generates enum definition and uses enum type for single enum parameter' do
        baml = SorbetBaml::TestFixtures::SingleEnumTool.to_baml

        expect(baml).to include('enum SearchCategory {')
        expect(baml).to include('category SearchCategory')
        expect(baml).to include('class single_enum {')
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

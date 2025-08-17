# typed: strict
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../fixtures/test_tools'

RSpec.describe SorbetBaml::ToolExtensions do
  before do
    # Extend T::Struct with tool extensions for testing
    T::Struct.extend(SorbetBaml::ToolExtensions)
  end

  describe 'to_baml_tool' do
    it 'converts simple tool to BAML' do
      baml = SorbetBaml::TestFixtures::ReplyTool.to_baml_tool

      expect(baml).to eq(<<~BAML.chomp)
        class ReplyTool {
          response string
        }
      BAML
    end

    it 'converts tool with action field' do
      baml = SorbetBaml::TestFixtures::StopTool.to_baml_tool

      expect(baml).to eq(<<~BAML.chomp)
        class StopTool {
          action string
        }
      BAML
    end

    it 'converts tool with multiple fields' do
      baml = SorbetBaml::TestFixtures::SearchTool.to_baml_tool

      expect(baml).to eq(<<~BAML.chomp)
        class SearchTool {
          query string
          limit int?
        }
      BAML
    end

    it 'converts tool with complex types' do
      baml = SorbetBaml::TestFixtures::UserCreateTool.to_baml_tool

      expect(baml).to eq(<<~BAML.chomp)
        class UserCreateTool {
          name string
          tags string[]
          preferences map<string, string>
        }
      BAML
    end

    it 'disables descriptions when requested' do
      baml = SorbetBaml::TestFixtures::SearchTool.to_baml_tool(include_descriptions: false)

      expect(baml).to eq(<<~BAML.chomp)
        class SearchTool {
          query string
          limit int?
        }
      BAML
    end

    it 'supports custom indentation' do
      baml = SorbetBaml::TestFixtures::ReplyTool.to_baml_tool(indent_size: 4)

      expect(baml).to eq(<<~BAML.chomp)
        class ReplyTool {
            response string
        }
      BAML
    end
  end

  describe 'baml_tool_definition' do
    it 'is an alias for to_baml_tool' do
      tool_def = SorbetBaml::TestFixtures::ReplyTool.baml_tool_definition
      to_baml = SorbetBaml::TestFixtures::ReplyTool.to_baml_tool

      expect(tool_def).to eq(to_baml)
    end
  end
end

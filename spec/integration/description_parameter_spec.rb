# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe 'Description Parameter Support Integration' do
  describe 'T::Struct with description parameters' do
    it 'converts T::Struct with description parameters to BAML' do
      # Define a struct with description parameters
      class TaskDecomposition < T::Struct
        const :research_topic, String, description: 'The main research topic being investigated'
        const :context, String, description: 'Additional context or constraints for the research'
        const :complexity_level, String, description: 'Target complexity level for the decomposition'
        const :subtasks, T::Array[String], description: 'Autonomously generated list of research subtasks'
      end

      baml = TaskDecomposition.to_baml(include_descriptions: true)

      expect(baml).to include('class TaskDecomposition {')
      expect(baml).to include('research_topic string @description("The main research topic being investigated")')
      expect(baml).to include('context string @description("Additional context or constraints for the research")')
      expect(baml).to include('complexity_level string @description("Target complexity level for the decomposition")')
      expect(baml).to include('subtasks string[] @description("Autonomously generated list of research subtasks")')
      expect(baml).to include('}')
    end

    it 'prioritizes description parameters over Ruby comments' do
      # Create a test file with comments that should be ignored in favor of description parameters
      test_file = Tempfile.new(['priority_test', '.rb'])
      test_file.write(<<~RUBY)
        class MixedDescriptions < T::Struct
          # This comment should be ignored
          const :research_topic, String, description: "Parameter description for research topic"
        #{'  '}
          # This comment should also be ignored#{'  '}
          const :context, String, description: "Parameter description for context"
        end
      RUBY
      test_file.close

      # Define the actual struct with description parameters
      class MixedDescriptions < T::Struct
        const :research_topic, String, description: 'Parameter description for research topic'
        const :context, String, description: 'Parameter description for context'
      end

      # Mock the source file finding to return our test file
      allow(SorbetBaml::CommentExtractor).to receive(:find_source_file).and_return(test_file.path)

      baml = MixedDescriptions.to_baml(include_descriptions: true)

      # Should use description parameters, not comments
      expect(baml).to include('research_topic string @description("Parameter description for research topic")')
      expect(baml).to include('context string @description("Parameter description for context")')

      # Should NOT include comment text
      expect(baml).not_to include('This comment should be ignored')

      test_file.unlink
    end

    it 'falls back to comments when description parameters are not available' do
      test_file = Tempfile.new(['fallback_test', '.rb'])
      test_file.write(<<~RUBY)
        class FallbackTest < T::Struct
          # This comment should be used as fallback
          const :name, String
        #{'  '}
          # Another comment for fallback
          const :email, String
        end
      RUBY
      test_file.close

      # Define struct without description parameters
      class FallbackTest < T::Struct
        const :name, String
        const :email, String
      end

      allow(SorbetBaml::CommentExtractor).to receive(:find_source_file).and_return(test_file.path)

      baml = FallbackTest.to_baml(include_descriptions: true)

      expect(baml).to include('name string @description("This comment should be used as fallback")')
      expect(baml).to include('email string @description("Another comment for fallback")')

      test_file.unlink
    end

    it 'handles mixed scenarios - some fields with description params, others need comment fallback' do
      test_file = Tempfile.new(['mixed_scenario_test', '.rb'])
      test_file.write(<<~RUBY)
        class MixedScenario < T::Struct
          # Comment for field without description parameter
          const :field_without_param, String
        #{'  '}
          const :field_with_param, String, description: "Parameter description here"
        end
      RUBY
      test_file.close

      # Define struct with mixed description sources
      class MixedScenario < T::Struct
        const :field_without_param, String
        const :field_with_param, String, description: 'Parameter description here'
      end

      allow(SorbetBaml::CommentExtractor).to receive(:find_source_file).and_return(test_file.path)

      baml = MixedScenario.to_baml(include_descriptions: true)

      # Description parameter should be used
      expect(baml).to include('field_with_param string @description("Parameter description here")')

      # Comment should be used as fallback
      expect(baml).to include('field_without_param string @description("Comment for field without description parameter")')

      test_file.unlink
    end
  end
end

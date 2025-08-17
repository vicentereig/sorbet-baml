# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SorbetBaml::DescriptionExtractor do
  describe '.extract_prop_descriptions' do
    context 'when props have description parameters' do
      it 'extracts descriptions from const declarations' do
        mock_class = Class.new(T::Struct) do
          const :name, String, description: "User's full name"
          const :age, Integer, description: 'Age in years'
          const :email, String, description: 'Primary email address'
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)

        expect(descriptions).to eq({
                                     'name' => "User's full name",
                                     'age' => 'Age in years',
                                     'email' => 'Primary email address'
                                   })
      end

      it 'extracts descriptions from prop declarations' do
        mock_class = Class.new(T::Struct) do
          prop :count, Integer, description: 'Number of items'
          prop :active, T::Boolean, description: 'Whether record is active'
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)

        expect(descriptions).to eq({
                                     'count' => 'Number of items',
                                     'active' => 'Whether record is active'
                                   })
      end

      it 'handles mixed const and prop declarations' do
        mock_class = Class.new(T::Struct) do
          const :id, String, description: 'Unique identifier'
          prop :status, String, description: 'Current status'
          const :created_at, String, description: 'Creation timestamp'
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)

        expect(descriptions).to eq({
                                     'id' => 'Unique identifier',
                                     'status' => 'Current status',
                                     'created_at' => 'Creation timestamp'
                                   })
      end

      it 'handles fields without descriptions' do
        mock_class = Class.new(T::Struct) do
          const :field_with_desc, String, description: 'Has description'
          const :field_without_desc, String
          prop :another_field, Integer
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)

        expect(descriptions).to eq({
                                     'field_with_desc' => 'Has description'
                                   })
      end

      it 'returns empty hash when no descriptions present' do
        mock_class = Class.new(T::Struct) do
          const :name, String
          prop :count, Integer
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)
        expect(descriptions).to eq({})
      end
    end

    context 'when class is not a T::Struct' do
      it 'returns empty hash for regular classes' do
        mock_class = Class.new

        descriptions = described_class.extract_prop_descriptions(mock_class)
        expect(descriptions).to eq({})
      end
    end

    context 'error handling' do
      it 'handles exceptions gracefully' do
        mock_class = Class.new(T::Struct) do
          def self.props
            raise StandardError, 'Something went wrong'
          end
        end

        descriptions = described_class.extract_prop_descriptions(mock_class)
        expect(descriptions).to eq({})
      end
    end
  end
end

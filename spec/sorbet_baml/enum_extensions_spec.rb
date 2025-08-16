# typed: false
# frozen_string_literal: true

require "spec_helper"
require "sorbet-runtime"
require_relative "../fixtures/test_enums"

RSpec.describe "T::Enum Extensions" do
  describe ".to_baml" do
    it "responds to to_baml method" do
      expect(SorbetBaml::TestFixtures::Status).to respond_to(:to_baml)
    end

    it "converts simple enum to BAML format" do
      result = SorbetBaml::TestFixtures::Status.to_baml
      
      expect(result).to eq(<<~BAML.strip)
        enum Status {
          "pending"
          "active"
          "inactive"
        }
      BAML
    end

    it "converts enum with multiple values" do
      result = SorbetBaml::TestFixtures::Priority.to_baml
      
      expect(result).to eq(<<~BAML.strip)
        enum Priority {
          "low"
          "medium"
          "high"
          "critical"
        }
      BAML
    end

    it "supports enum with different naming" do
      result = SorbetBaml::TestFixtures::UserRole.to_baml
      
      expect(result).to eq(<<~BAML.strip)
        enum UserRole {
          "admin"
          "user"
          "guest"
        }
      BAML
    end
  end

  describe ".baml_type_definition" do
    it "responds to baml_type_definition method" do
      expect(SorbetBaml::TestFixtures::Status).to respond_to(:baml_type_definition)
    end

    it "accepts options hash" do
      expect { SorbetBaml::TestFixtures::Status.baml_type_definition(indent_size: 4) }.not_to raise_error
    end

    it "respects indent_size option" do
      result = SorbetBaml::TestFixtures::Status.baml_type_definition(indent_size: 4)
      
      expect(result).to eq(<<~BAML.strip)
        enum Status {
            "pending"
            "active"
            "inactive"
        }
      BAML
    end

    it "behaves the same as to_baml when no options provided" do
      enum_class = SorbetBaml::TestFixtures::Status
      expect(enum_class.to_baml).to eq(enum_class.baml_type_definition)
    end
  end
end
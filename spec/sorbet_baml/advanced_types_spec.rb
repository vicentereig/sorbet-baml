# typed: false
# frozen_string_literal: true

require "spec_helper"
require "sorbet-runtime"
require_relative "../fixtures/complex_types"

RSpec.describe "Advanced Type Support" do
  describe "T::Hash types" do
    it "converts simple hash types to map syntax" do
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

  describe "T.any (union) types" do
    it "converts union types to pipe syntax" do
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

  describe "Complex combined types" do
    it "handles multiple advanced type features together" do
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

  describe "Edge cases" do
    it "handles nested hash types" do
      # Test that we can handle hash with complex value types
      result = SorbetBaml::TestFixtures::UserPreferences.to_baml
      expect(result).to include("map<string, string[]>")
    end

    it "handles union with nil properly" do
      result = SorbetBaml::TestFixtures::FlexibleData.to_baml
      expect(result).to include("(string | int)?")
    end
  end
end
# typed: false
# frozen_string_literal: true

require "spec_helper"
require "sorbet-runtime"
require_relative "../fixtures/test_structs"

RSpec.describe SorbetBaml::Converter do
  describe ".from_struct" do
    context "with a simple struct" do
      it "converts basic types correctly" do
        result = described_class.from_struct(SorbetBaml::TestFixtures::SimpleUser)
        
        expect(result).to eq(<<~BAML.strip)
          class SimpleUser {
            name string
            age int
          }
        BAML
      end
    end
    
    context "with optional fields" do
      it "converts nilable types to optional" do
        result = described_class.from_struct(SorbetBaml::TestFixtures::UserWithOptionals)
        
        expect(result).to eq(<<~BAML.strip)
          class UserWithOptionals {
            name string
            email string?
            age int?
          }
        BAML
      end
    end
    
    context "with array fields" do
      it "converts array types correctly" do
        result = described_class.from_struct(SorbetBaml::TestFixtures::UserWithArrays)
        
        expect(result).to eq(<<~BAML.strip)
          class UserWithArrays {
            tags string[]
            scores int[]
          }
        BAML
      end
    end
    
    context "with nested structs" do
      it "references nested struct types" do
        result = described_class.from_struct(SorbetBaml::TestFixtures::UserWithAddress)
        
        expect(result).to eq(<<~BAML.strip)
          class UserWithAddress {
            name string
            address Address
          }
        BAML
      end
    end
  end
  
  describe ".from_structs" do
    it "converts multiple structs" do
      result = described_class.from_structs([SorbetBaml::TestFixtures::Address, SorbetBaml::TestFixtures::User])
      
      expect(result).to eq(<<~BAML.strip)
        class Address {
          street string
          city string
        }
        
        class User {
          name string
          address Address
        }
      BAML
    end
  end
end
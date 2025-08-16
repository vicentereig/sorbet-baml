# typed: false
# frozen_string_literal: true

require "spec_helper"
require "sorbet-runtime"

RSpec.describe SorbetBaml::Converter do
  describe ".from_struct" do
    context "with a simple struct" do
      before do
        stub_const("SimpleUser", Class.new(T::Struct) do
          const :name, String
          const :age, Integer
        end)
      end
      
      it "converts basic types correctly" do
        result = described_class.from_struct(SimpleUser)
        
        expect(result).to eq(<<~BAML.strip)
          class SimpleUser {
            name string
            age int
          }
        BAML
      end
    end
    
    context "with optional fields" do
      before do
        stub_const("UserWithOptionals", Class.new(T::Struct) do
          const :name, String
          const :email, T.nilable(String)
          const :age, T.nilable(Integer)
        end)
      end
      
      it "converts nilable types to optional" do
        result = described_class.from_struct(UserWithOptionals)
        
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
      before do
        stub_const("UserWithArrays", Class.new(T::Struct) do
          const :tags, T::Array[String]
          const :scores, T::Array[Integer]
        end)
      end
      
      it "converts array types correctly" do
        result = described_class.from_struct(UserWithArrays)
        
        expect(result).to eq(<<~BAML.strip)
          class UserWithArrays {
            tags string[]
            scores int[]
          }
        BAML
      end
    end
    
    context "with nested structs" do
      before do
        stub_const("Address", Class.new(T::Struct) do
          const :street, String
          const :city, String
        end)
        
        stub_const("UserWithAddress", Class.new(T::Struct) do
          const :name, String
          const :address, Address
        end)
      end
      
      it "references nested struct types" do
        result = described_class.from_struct(UserWithAddress)
        
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
    before do
      stub_const("Address", Class.new(T::Struct) do
        const :street, String
        const :city, String
      end)
      
      stub_const("User", Class.new(T::Struct) do
        const :name, String
        const :address, Address
      end)
    end
    
    it "converts multiple structs" do
      result = described_class.from_structs([Address, User])
      
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
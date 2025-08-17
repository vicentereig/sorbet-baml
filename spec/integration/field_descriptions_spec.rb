# typed: false
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Field Descriptions Integration' do
  # Define documented test classes in this file so we can extract comments

  # User profile with detailed field documentation
  class UserProfile < T::Struct
    # User's full legal name for official records
    const :full_name, String

    # Age in years, must be 18 or older
    const :age, Integer

    # Primary email address for communication
    const :email, String

    # Optional phone number for SMS notifications
    const :phone, T.nilable(String)

    # List of user's interests and hobbies
    const :interests, T::Array[String]

    # User preferences as key-value pairs
    const :preferences, T::Hash[String, String]
  end

  # Account status enumeration with descriptions
  class AccountStatus < T::Enum
    enums do
      # Account is active and in good standing
      Active = new('active')

      # Account is temporarily suspended due to policy violation
      Suspended = new('suspended')

      # Account is permanently closed at user request
      Closed = new('closed')
    end
  end

  describe 'struct field descriptions' do
    it 'includes field descriptions when requested' do
      baml = UserProfile.to_baml(include_descriptions: true)

      expect(baml).to include("@description(\"User's full legal name for official records\")")
      expect(baml).to include('@description("Age in years, must be 18 or older")')
      expect(baml).to include('@description("Primary email address for communication")')
      expect(baml).to include('@description("Optional phone number for SMS notifications")')
      expect(baml).to include("@description(\"List of user's interests and hobbies\")")
      expect(baml).to include('@description("User preferences as key-value pairs")')
    end

    it 'includes field descriptions by default (smart defaults)' do
      baml = UserProfile.to_baml

      expect(baml).to include('@description')
      expect(baml).to include('full_name string')
      expect(baml).to include('age int')
      expect(baml).to include('email string')
    end

    it 'can disable descriptions when explicitly set to false' do
      baml = UserProfile.to_baml(include_descriptions: false)

      expect(baml).not_to include('@description')
      expect(baml).to include('full_name string')
      expect(baml).to include('age int')
      expect(baml).to include('email string')
    end

    it 'generates complete BAML with descriptions' do
      baml = UserProfile.to_baml(include_descriptions: true)

      expected_lines = [
        'class UserProfile {',
        "  full_name string @description(\"User's full legal name for official records\")",
        '  age int @description("Age in years, must be 18 or older")',
        '  email string @description("Primary email address for communication")',
        '  phone string? @description("Optional phone number for SMS notifications")',
        "  interests string[] @description(\"List of user's interests and hobbies\")",
        '  preferences map<string, string> @description("User preferences as key-value pairs")',
        '}'
      ]

      expected_lines.each do |line|
        expect(baml).to include(line)
      end
    end
  end

  describe 'enum value descriptions' do
    it 'includes enum descriptions when requested' do
      baml = AccountStatus.to_baml(include_descriptions: true)

      expect(baml).to include('@description("Account is active and in good standing")')
      expect(baml).to include('@description("Account is temporarily suspended due to policy violation")')
      expect(baml).to include('@description("Account is permanently closed at user request")')
    end

    it 'includes enum descriptions by default (smart defaults)' do
      baml = AccountStatus.to_baml

      expect(baml).to include('@description')
      expect(baml).to include('"active"')
      expect(baml).to include('"suspended"')
      expect(baml).to include('"closed"')
    end

    it 'can disable enum descriptions when explicitly set to false' do
      baml = AccountStatus.to_baml(include_descriptions: false)

      expect(baml).not_to include('@description')
      expect(baml).to include('"active"')
      expect(baml).to include('"suspended"')
      expect(baml).to include('"closed"')
    end

    it 'generates complete enum BAML with descriptions' do
      baml = AccountStatus.to_baml(include_descriptions: true)

      expected_lines = [
        'enum AccountStatus {',
        '  "active" @description("Account is active and in good standing")',
        '  "suspended" @description("Account is temporarily suspended due to policy violation")',
        '  "closed" @description("Account is permanently closed at user request")',
        '}'
      ]

      expected_lines.each do |line|
        expect(baml).to include(line)
      end
    end
  end

  describe 'combined struct and enum with descriptions' do
    class Account < T::Struct
      # Unique account identifier
      const :id, String

      # Current account status
      const :status, AccountStatus

      # Account holder's profile information
      const :profile, UserProfile
    end

    it 'includes descriptions for all types when using dependencies' do
      baml = Account.to_baml(include_dependencies: true, include_descriptions: true)

      # Should include AccountStatus enum with descriptions
      expect(baml).to include('  "active" @description("Account is active and in good standing")')

      # Should include UserProfile struct with descriptions
      expect(baml).to include("  full_name string @description(\"User's full legal name for official records\")")

      # Should include Account struct with descriptions
      expect(baml).to include('  id string @description("Unique account identifier")')
      expect(baml).to include('  status AccountStatus @description("Current account status")')
      expect(baml).to include("  profile UserProfile @description(\"Account holder's profile information\")")
    end
  end

  describe 'backwards compatibility' do
    it 'maintains API compatibility with new smart defaults' do
      # API should work with smart defaults enabled
      baml = UserProfile.to_baml
      expect(baml).to be_a(String)
      expect(baml).to include('class UserProfile')
      expect(baml).to include('@description') # Smart default: descriptions enabled

      # Legacy API should work without smart defaults (backwards compatibility)
      baml_legacy = SorbetBaml.from_struct(UserProfile)
      expect(baml_legacy).to be_a(String)
      expect(baml_legacy).to include('class UserProfile')
    end
  end
end

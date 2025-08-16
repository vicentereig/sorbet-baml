# typed: false
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  module TestFixtures
    # Test independent types that should be included as dependencies
    class ContactInfo < T::Struct
      const :email, String
      const :phone, T.nilable(String)
    end

    class Category < T::Struct
      const :name, String
      const :description, String
    end

    class Vendor < T::Struct
      const :name, String
      const :contact, ContactInfo
    end

    class Product < T::Struct
      const :name, String
      const :category, Category
      const :vendor, Vendor
    end

    # Simple case - no circular references for now
    # We'll test the dependency discovery and ordering
    class OrderItem < T::Struct
      const :product, Product
      const :quantity, Integer
      const :price, Float
    end
  end
end
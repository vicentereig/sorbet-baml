# typed: false
# frozen_string_literal: true

require 'spec_helper'
require 'sorbet-runtime'
require_relative '../fixtures/circular_refs'

RSpec.describe 'Dependency Management' do
  describe 'include_dependencies option' do
    it 'includes all referenced types when include_dependencies is true' do
      result = SorbetBaml::TestFixtures::Product.to_baml(include_dependencies: true)

      # Should include Product, Category, Vendor, and ContactInfo
      expect(result).to include('class Product {')
      expect(result).to include('class Category {')
      expect(result).to include('class Vendor {')
      expect(result).to include('class ContactInfo {')
    end

    it 'only includes the main type when include_dependencies is false' do
      result = SorbetBaml::TestFixtures::Product.to_baml(include_dependencies: false)

      expect(result).to include('class Product {')
      expect(result).not_to include('class Category {')
      expect(result).not_to include('class Vendor {')
      expect(result).not_to include('class ContactInfo {')
    end

    it 'defaults to including dependencies (smart defaults)' do
      result = SorbetBaml::TestFixtures::Product.to_baml

      expect(result).to include('class Product {')
      expect(result).to include('class Category {')
      expect(result).to include('class Vendor {')
      expect(result).to include('class ContactInfo {')
    end

    it 'can disable dependencies when explicitly set to false' do
      result = SorbetBaml::TestFixtures::Product.to_baml(include_dependencies: false)

      expect(result).to include('class Product {')
      expect(result).not_to include('class Category {')
      expect(result).not_to include('class Vendor {')
      expect(result).not_to include('class ContactInfo {')
    end

    it 'orders dependencies before the main type' do
      result = SorbetBaml::TestFixtures::Product.to_baml(include_dependencies: true)

      # ContactInfo should come before Vendor (which references it)
      contact_info_pos = result.index('class ContactInfo {')
      vendor_pos = result.index('class Vendor {')
      product_pos = result.index('class Product {')

      expect(contact_info_pos).to be < vendor_pos
      expect(vendor_pos).to be < product_pos
    end

    it 'handles deeper dependency chains' do
      result = SorbetBaml::TestFixtures::OrderItem.to_baml(include_dependencies: true)

      # Should include OrderItem -> Product -> Category & Vendor -> ContactInfo
      expect(result).to include('class OrderItem {')
      expect(result).to include('class Product {')
      expect(result).to include('class Category {')
      expect(result).to include('class Vendor {')
      expect(result).to include('class ContactInfo {')
    end
  end

  describe 'dependency ordering' do
    it 'places independent types first' do
      result = SorbetBaml::TestFixtures::Product.to_baml(include_dependencies: true)

      # Category and ContactInfo have no dependencies, so should come first
      category_pos = result.index('class Category {')
      contact_info_pos = result.index('class ContactInfo {')

      # Both should come before types that depend on them
      vendor_pos = result.index('class Vendor {')
      product_pos = result.index('class Product {')

      expect(category_pos).to be < product_pos
      expect(contact_info_pos).to be < vendor_pos
    end

    it 'properly orders multi-level dependencies' do
      result = SorbetBaml::TestFixtures::OrderItem.to_baml(include_dependencies: true)

      # ContactInfo -> Vendor -> Product -> OrderItem
      contact_info_pos = result.index('class ContactInfo {')
      vendor_pos = result.index('class Vendor {')
      product_pos = result.index('class Product {')
      order_item_pos = result.index('class OrderItem {')

      expect(contact_info_pos).to be < vendor_pos
      expect(vendor_pos).to be < product_pos
      expect(product_pos).to be < order_item_pos
    end
  end
end

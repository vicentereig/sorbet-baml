#!/usr/bin/env ruby
# typed: false

require_relative '../lib/sorbet_baml'

puts '🎯 Description Parameter Support Demo'
puts '=' * 50

# Example 1: Basic description parameters
class User < T::Struct
  const :name, String, description: "User's full legal name"
  prop :age, Integer, description: 'Age in years'
  const :email, T.nilable(String), description: 'Optional email address for notifications'
  const :interests, T::Array[String], description: 'List of user hobbies and interests'
end

puts "\n1. Basic T::Struct with description parameters:"
puts User.to_baml

# Example 2: Mixed description sources (parameters + comments)
class Product < T::Struct
  # This comment will be used as fallback
  const :id, String

  const :name, String, description: 'Product name for display'

  # Price in USD cents
  prop :price_cents, Integer

  const :category, String, description: 'Product category classification'
end

puts "\n2. Mixed description sources (parameters take priority):"
puts Product.to_baml

# Example 3: Complex nested types with descriptions
class Order < T::Struct
  const :id, String, description: 'Unique order identifier'
  const :customer, User, description: 'Customer who placed the order'
  const :items, T::Array[Product], description: 'List of ordered products'
  const :total_cents, Integer, description: 'Total order value in USD cents'
  const :status, String, description: 'Current order processing status'
end

puts "\n3. Complex nested types with dependencies:"
puts Order.to_baml

puts "\n✨ Beautiful, readable, and LLM-friendly!"
puts '🚀 Perfect for DSPy.rb, autonomous agents, and structured LLM outputs'

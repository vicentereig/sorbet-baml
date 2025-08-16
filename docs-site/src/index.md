---
layout: default
title: "sorbet-baml"
description: "Ruby-idiomatic conversion from Sorbet types to BAML for efficient LLM prompting. 60% fewer tokens than JSON Schema while maintaining complete type information."
---

<div class="text-center mb-12">
  <h1 class="text-4xl font-bold text-gray-900 mb-4">sorbet-baml</h1>
  <p class="text-xl text-gray-600 max-w-3xl mx-auto">
    Ruby-idiomatic conversion from Sorbet types to BAML (Boundary AI Markup Language) for efficient LLM prompting.
  </p>
  
  <div class="flex flex-wrap justify-center gap-4 mt-8">
    <img src="https://img.shields.io/gem/v/sorbet-baml" alt="Gem Version" />
    <img src="https://img.shields.io/gem/dt/sorbet-baml" alt="Total Downloads" />
    <img src="https://img.shields.io/github/license/vicentereig/sorbet-baml" alt="License" />
    <img src="https://img.shields.io/badge/Sorbet-compatible-blue" alt="Sorbet Compatible" />
  </div>
  
  <div class="flex flex-wrap justify-center gap-4 mt-6">
    <a href="/sorbet-baml/getting-started/" class="bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors">
      Get Started
    </a>
    <a href="https://github.com/vicentereig/sorbet-baml" class="bg-gray-100 text-gray-700 px-6 py-3 rounded-lg font-medium hover:bg-gray-200 transition-colors">
      View on GitHub
    </a>
  </div>
</div>

## Why BAML?

BAML uses approximately **60% fewer tokens** than JSON Schema while maintaining complete type information, making your LLM interactions more efficient and cost-effective.

<div class="bg-blue-50 border border-blue-200 rounded-lg p-6 my-8">
  <h3 class="text-lg font-semibold text-blue-900 mb-3">🚀 Token Efficiency Comparison</h3>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <div>
      <strong>JSON Schema:</strong> ~680 tokens
    </div>
    <div>
      <strong>BAML:</strong> ~320 tokens <span class="text-blue-600 font-semibold">(53% reduction)</span>
    </div>
  </div>
  <p class="text-blue-800 mt-3">
    Real-world comparison from production agentic workflows using complex nested types, enums, and arrays.
  </p>
</div>

## Quick Example

```ruby
# Define a Sorbet struct
class User < T::Struct
  const :name, String
  const :age, Integer
  const :email, T.nilable(String)
end

# Convert to BAML (Ruby-idiomatic API)
require 'sorbet-baml'
User.to_baml
```

**Generated BAML:**
```baml
class User {
  name string
  age int
  email string?
}
```

## Key Features

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 my-8">
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">🎯 Ruby-Idiomatic API</h3>
    <p class="text-gray-600">Every T::Struct and T::Enum gets a natural <code>.to_baml</code> method that feels native to Ruby.</p>
  </div>
  
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">🧠 Smart Defaults</h3>
    <p class="text-gray-600">Field descriptions and dependencies included automatically for better LLM understanding.</p>
  </div>
  
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">📝 Field Descriptions</h3>
    <p class="text-gray-600">Extracts comments from source code to provide crucial context for autonomous agents.</p>
  </div>
  
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">🔗 Dependency Management</h3>
    <p class="text-gray-600">Automatically includes all referenced types with proper topological sorting.</p>
  </div>
  
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">✅ Type-Safe</h3>
    <p class="text-gray-600">Full Sorbet type checking throughout the gem with 100% test coverage.</p>
  </div>
  
  <div class="bg-white p-6 rounded-lg border border-gray-200">
    <h3 class="font-semibold text-gray-900 mb-2">🏁 Production Ready</h3>
    <p class="text-gray-600">Complete type support, dependency management, and comprehensive test coverage.</p>
  </div>
</div>

## Complete Type Support

### Basic Types
- `String` → `string`
- `Integer` → `int` 
- `Float` → `float`
- `T::Boolean` → `bool`
- `Symbol` → `string`
- `Date/DateTime/Time` → `string`

### Complex Types
- `T.nilable(T)` → `T?` (optional types)
- `T::Array[T]` → `T[]` (arrays)
- `T::Hash[K,V]` → `map<K,V>` (hash maps)
- `T.any(T1, T2)` → `T1 | T2` (union types)

### Structured Types
- `T::Struct` → `class Name { ... }` (classes with fields)
- `T::Enum` → `enum Name { "value1" "value2" }` (enums)
- Nested structs with proper reference handling
- **Automatic dependency resolution** with topological sorting

## Perfect for Agentic Workflows

```ruby
# Define your autonomous research workflow types
class TaskDecomposition < T::Struct
  # The main research topic being investigated
  const :research_topic, String
  # Target complexity level for the decomposition
  const :complexity_level, ComplexityLevel
  # Autonomously generated list of research subtasks
  const :subtasks, T::Array[String]
end

# Generate BAML for LLM agents
prompt = <<~PROMPT
  You are an autonomous research agent. Analyze this topic and decompose it.
  
  Schema for your output:
  #{TaskDecomposition.to_baml}
  
  Topic: "Impact of AI on healthcare delivery systems"
PROMPT

# Use with any LLM provider
response = llm_client.chat(prompt)
result = TaskDecomposition.from_json(response.content)
```

## Installation

Add to your Gemfile:

```ruby
gem 'sorbet-baml'
```

Or install directly:

```bash
gem install sorbet-baml
```

---

<div class="text-center mt-12">
  <h2 class="text-2xl font-bold text-gray-900 mb-4">Ready to get started?</h2>
  <a href="/sorbet-baml/getting-started/" class="bg-blue-600 text-white px-8 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors inline-block">
    Read the Getting Started Guide →
  </a>
</div>
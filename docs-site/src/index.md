---
layout: default
title: "sorbet-baml"
description: "Ruby-idiomatic conversion from Sorbet types to BAML for efficient LLM prompting. 60% fewer tokens than JSON Schema while maintaining complete type information."
---

**sorbet-baml** converts your Sorbet types to BAML (Boundary AI Markup Language) with a simple, Ruby-idiomatic API.

BAML is a more efficient alternative to JSON Schema for LLM prompting - it uses about 60% fewer tokens while maintaining complete type information.

## Features

- **Ruby-idiomatic API**: Every `T::Struct` and `T::Enum` gets a `.to_baml` method
- **Efficient output**: ~60% fewer tokens than equivalent JSON Schema
- **Smart defaults**: Includes field descriptions and dependencies automatically  
- **Type-safe**: Full Sorbet compatibility with comprehensive test coverage
- **Dependency resolution**: Handles nested types with topological sorting

<div class="flex flex-wrap gap-4 my-8">
  <a href="/getting-started/" class="btn-primary">
    Get Started →
  </a>
  <a href="https://github.com/vicentereig/sorbet-baml" class="btn-secondary">
    View on GitHub
  </a>
</div>

<div class="flex flex-wrap justify-center gap-4 my-6">
  <img src="https://img.shields.io/gem/v/sorbet-baml" alt="Gem Version" />
  <img src="https://img.shields.io/gem/dt/sorbet-baml" alt="Total Downloads" />
  <img src="https://img.shields.io/github/license/vicentereig/sorbet-baml" alt="License" />
  <img src="https://img.shields.io/badge/Sorbet-compatible-blue" alt="Sorbet Compatible" />
</div>

## Why BAML?

BAML uses approximately <strong>60% fewer tokens</strong> than JSON Schema while maintaining complete type information, making your LLM interactions more efficient and cost-effective.

<div class="card-once my-8">
  <h3 class="text-lg font-semibold text-once-blue-900 mb-3 font-sans">Token Efficiency Comparison</h3>
  <div class="space-y-2">
    <div class="flex justify-between items-center">
      <span><strong>JSON Schema:</strong></span> 
      <span class="font-mono">~680 tokens</span>
    </div>
    <div class="flex justify-between items-center">
      <span><strong>BAML:</strong></span>
      <span class="font-mono">~320 tokens <span class="text-once-blue-700 font-semibold">(53% reduction)</span></span>
    </div>
  </div>
  <p class="text-once-blue-700 mt-4 text-sm">
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

<strong>Generated BAML:</strong>
```baml
class User {
  name string
  age int
  email string?
}
```


## Complete Type Support

<div class="grid grid-cols-1 md:grid-cols-3 gap-8 my-8">
  <div class="space-y-4">
    <h3 class="font-semibold text-once-blue-900 text-lg font-sans">Basic Types</h3>
    <div class="space-y-2 text-sm font-mono">
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">String</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">string</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">Integer</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">int</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">Float</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">float</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">T::Boolean</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">bool</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">Symbol</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">string</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700 text-xs">Date/DateTime/Time</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">string</code>
      </div>
    </div>
  </div>

  <div class="space-y-4">
    <h3 class="font-semibold text-once-blue-900 text-lg font-sans">Complex Types</h3>
    <div class="space-y-2 text-sm font-mono">
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700 text-xs">T.nilable(T)</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">T?</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700">T::Array[T]</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">T[]</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700 text-xs">T::Hash[K,V]</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600 text-xs">map&lt;K,V&gt;</code>
      </div>
      <div class="flex justify-between items-center">
        <code class="text-once-blue-700 text-xs">T.any(T1, T2)</code>
        <span class="text-once-gray-500">→</span>
        <code class="text-once-blue-600">T1 | T2</code>
      </div>
    </div>
    <p class="text-xs text-once-gray-600">Optional types, arrays, maps, unions</p>
  </div>

  <div class="space-y-4">
    <h3 class="font-semibold text-once-blue-900 text-lg font-sans">Structured Types</h3>
    <div class="space-y-2 text-sm font-mono">
      <div class="space-y-1">
        <div class="flex justify-between items-center">
          <code class="text-once-blue-700">T::Struct</code>
          <span class="text-once-gray-500">→</span>
          <code class="text-once-blue-600 text-xs">class Name { ... }</code>
        </div>
        <div class="flex justify-between items-center">
          <code class="text-once-blue-700">T::Enum</code>
          <span class="text-once-gray-500">→</span>
          <code class="text-once-blue-600 text-xs">enum Name { ... }</code>
        </div>
      </div>
    </div>
    <div class="space-y-1 text-xs text-once-blue-700">
      <p>• Nested structs with proper references</p>
      <p>• <strong>Automatic dependency resolution</strong></p>
      <p>• Topological sorting</p>
    </div>
  </div>
</div>

## Usage in LLM Prompts

```ruby
# Define your types
class TaskDecomposition < T::Struct
  const :research_topic, String
  const :complexity_level, ComplexityLevel
  const :subtasks, T::Array[String]
end

# Include BAML schema in prompts
prompt = <<~PROMPT
  Analyze this topic and decompose it into subtasks.
  
  Return your response in this format:
  #{TaskDecomposition.to_baml}
PROMPT
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


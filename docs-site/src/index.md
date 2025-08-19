---
layout: default
title: "sorbet-baml"
description: "Ruby-idiomatic conversion from Sorbet types to BAML for efficient LLM prompting. 60% fewer tokens than JSON Schema while maintaining complete type information."
---

<div class="prose prose-lg max-w-none">

<p>Something happened to schema generation.</p>

<p>You used to define your types **once**, convert them, and use them efficiently. Whether for validation, documentation, or LLM prompting, it felt straightforward. And it was.</p>

<p>Today, most type conversion is verbose and inefficient. JSON Schema bloats your prompts with unnecessary metadata. Every field needs explicit definitions. Token counts skyrocket, and your LLM interactions become expensive.</p>

<p>Add up your API costs from verbose schemas last month. You should own more efficient tooling by now.</p>

<p>JSON Schema still makes sense for many use cases, but BAML's grip will tighten. Type conversion used to be hopelessly verbose, but modern markup is simpler now and vastly improved. Plus, developers are hungry to optimize their LLM costs again, tired of being subservient to token-heavy schemas.</p>

<p>**Once** upon a time you defined your types efficiently, you controlled your token usage, and your prompting performance was your own business. We think it's that time again.</p>

<p>Introducing **sorbet-baml**, Ruby-idiomatic BAML generation from [Sorbet](https://sorbet.org) types.</p>

<ul class="list-dash my-8">
  <li>Define once, convert efficiently.</li>
  <li>60% fewer tokens than JSON Schema.</li>
  <li>Ruby-idiomatic API with natural `.to_baml` methods.</li>
  <li>Simple and straightforward, not enterprisey and bloated.</li>
  <li>For better LLM performance.</li>
</ul>

<p>So far there's one **sorbet-baml** gem:</p>

<ul class="list-dash my-8">
  <li>**sorbet-baml:** Ruby-idiomatic conversion from Sorbet types to BAML.</li>
</ul>

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

</div>

## Why BAML?

BAML uses approximately **60% fewer tokens** than JSON Schema while maintaining complete type information, making your LLM interactions more efficient and cost-effective.

<div class="card-once my-8">
  <h3 class="text-lg font-semibold text-once-black mb-3">Token Efficiency Comparison</h3>
  <div class="space-y-2">
    <div class="flex justify-between items-center">
      <span>**JSON Schema:**</span> 
      <span class="font-mono">~680 tokens</span>
    </div>
    <div class="flex justify-between items-center">
      <span>**BAML:**</span>
      <span class="font-mono">~320 tokens <span class="text-once-gray-600 font-semibold">(53% reduction)</span></span>
    </div>
  </div>
  <p class="text-once-gray-600 mt-4 text-sm">
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
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Ruby-Idiomatic API</h3>
    <p class="text-once-gray-600">Every T::Struct and T::Enum gets a natural `.to_baml` method that feels native to Ruby.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Smart Defaults</h3>
    <p class="text-once-gray-600">Field descriptions and dependencies included automatically for better LLM understanding.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Field Descriptions</h3>
    <p class="text-once-gray-600">Extracts comments from source code to provide crucial context for autonomous agents.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Dependency Management</h3>
    <p class="text-once-gray-600">Automatically includes all referenced types with proper topological sorting.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Type-Safe</h3>
    <p class="text-once-gray-600">Full Sorbet type checking throughout the gem with 100% test coverage.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Tool Definitions</h3>
    <p class="text-once-gray-600">Generate BAML tool specifications for function calling and agentic workflows.</p>
  </div>
  
  <div class="card-once">
    <h3 class="font-semibold text-once-black mb-2">Production Ready</h3>
    <p class="text-once-gray-600">Complete type support, dependency management, and comprehensive test coverage.</p>
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

<div class="text-center mt-16">
  <h2 class="text-2xl font-bold text-once-black mb-4">Ready to get started?</h2>
  <a href="/getting-started/" class="btn-primary">
    Read the Getting Started Guide →
  </a>
</div>
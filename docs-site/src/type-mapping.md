---
layout: doc
title: "Type Mapping Reference"
description: "Complete mapping between Sorbet types and BAML output. Learn how every Sorbet type converts to efficient BAML format."
---

# Type Mapping Reference

Complete mapping between Sorbet types and BAML output for autonomous LLM workflows. All listed types are **fully supported** with automatic field descriptions.

## Basic Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `String` | `string` | `name string` |
| `Integer` | `int` | `age int` |
| `Float` | `float` | `price float` |
| `T::Boolean` | `bool` | `active bool` |
| `NilClass` | `null` | `null` |
| `Symbol` | `string` | `status string` |
| `Date/DateTime/Time` | `string` | `created_at string` |

## Optional Types (T.nilable)

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T.nilable(String)` | `string?` | `email string?` |
| `T.nilable(Integer)` | `int?` | `age int?` |
| `T.nilable(MyStruct)` | `MyStruct?` | `address Address?` |

## Collection Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T::Array[String]` | `string[]` | `tags string[]` |
| `T::Array[Integer]` | `int[]` | `scores int[]` |
| `T::Array[MyStruct]` | `MyStruct[]` | `addresses Address[]` |

## Hash/Map Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T::Hash[String, String]` | `map<string, string>` | `metadata map<string, string>` |
| `T::Hash[String, Integer]` | `map<string, int>` | `counts map<string, int>` |
| `T::Hash[Symbol, String]` | `map<string, string>` | `config map<string, string>` |

## Union Types (T.any)

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T.any(String, Integer)` | `string \| int` | `value string \| int` |
| `T.any(String, Integer, Float)` | `string \| int \| float` | `mixed string \| int \| float` |
| `T.nilable(T.any(String, Integer))` | `(string \| int)?` | `optional (string \| int)?` |

## Complex Collection Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T::Array[T.any(String, Integer)]` | `(string \| int)[]` | `mixed_array (string \| int)[]` |
| `T::Hash[String, T.any(String, Integer)]` | `map<string, string \| int>` | `settings map<string, string \| int>` |
| `T::Hash[String, T::Array[String]]` | `map<string, string[]>` | `labels map<string, string[]>` |

## Structured Types

### T::Struct to BAML Classes (Research Workflow Example)

```ruby
class ConfidenceLevel < T::Enum
  enums do
    # Low confidence, requires further verification
    Low = new('low')
    # High confidence, strongly supported by evidence
    High = new('high')
  end
end

class ResearchFindings < T::Struct
  # Detailed research findings and analysis
  const :findings, String
  # Key actionable insights extracted
  const :key_insights, T::Array[String]
  # Assessment of evidence quality
  const :evidence_quality, ConfidenceLevel
  # Confidence score (1-10 scale)
  const :confidence_score, Integer
end
```

```ruby
ResearchFindings.to_baml
```

**Generated BAML:**
```baml
enum ConfidenceLevel {
  "low" @description("Low confidence, requires further verification")
  "high" @description("High confidence, strongly supported by evidence")
}

class ResearchFindings {
  findings string @description("Detailed research findings and analysis")
  key_insights string[] @description("Key actionable insights extracted")
  evidence_quality ConfidenceLevel @description("Assessment of evidence quality")
  confidence_score int @description("Confidence score (1-10 scale)")
}
```

### T::Enum to BAML Enums (Task Classification)

```ruby
class TaskType < T::Enum
  enums do
    # Literature review and information gathering
    Research = new('research')
    # Data analysis and statistical interpretation
    Analysis = new('analysis')
    # Combining multiple sources into coherent insights
    Synthesis = new('synthesis')
  end
end

class ResearchTask < T::Struct
  # Clear description of the research objective
  const :objective, String
  # Type of research task to be performed
  const :task_type, TaskType
end
```

```ruby
[TaskType, ResearchTask].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum TaskType {
  "research" @description("Literature review and information gathering")
  "analysis" @description("Data analysis and statistical interpretation")
  "synthesis" @description("Combining multiple sources into coherent insights")
}

class ResearchTask {
  objective string @description("Clear description of the research objective")
  task_type TaskType @description("Type of research task to be performed")
}
```

### Complex Real-World Example (Autonomous Research Agent)

```ruby
class ComplexityLevel < T::Enum
  enums do
    # Basic analysis requiring straightforward research
    Basic = new('basic')
    # Advanced analysis requiring deep domain expertise
    Advanced = new('advanced')
  end
end

class TaskDecomposition < T::Struct
  # The main research topic being investigated
  const :research_topic, String
  # Target complexity level for the decomposition
  const :complexity_level, ComplexityLevel
  # Autonomously generated list of research subtasks
  const :subtasks, T::Array[String]
  # Strategic priority rankings (1-5 scale) for each subtask
  const :priority_order, T::Array[Integer]
  # Task dependency relationships for optimal sequencing
  const :dependencies, T::Array[String]
  # Key-value metadata for agent coordination
  const :agent_metadata, T::Hash[String, T.any(String, Integer)]
end
```

```ruby
[ComplexityLevel, TaskDecomposition].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum ComplexityLevel {
  "basic" @description("Basic analysis requiring straightforward research")
  "advanced" @description("Advanced analysis requiring deep domain expertise")
}

class TaskDecomposition {
  research_topic string @description("The main research topic being investigated")
  complexity_level ComplexityLevel @description("Target complexity level for the decomposition")
  subtasks string[] @description("Autonomously generated list of research subtasks")
  priority_order int[] @description("Strategic priority rankings (1-5 scale) for each subtask")
  dependencies string[] @description("Task dependency relationships for optimal sequencing")
  agent_metadata map<string, string | int> @description("Key-value metadata for agent coordination")
}
```

## Advanced Features

### Dependency Management

```ruby
# Dependencies automatically included with smart defaults
TaskDecomposition.to_baml
# Outputs ComplexityLevel enum, then TaskDecomposition class in correct order
```

### Field Descriptions (Included by Default)

```ruby
# Smart defaults extract field descriptions from comments
TaskDecomposition.to_baml
# Outputs BAML with @description() annotations for LLM context
```

### Custom Formatting

```ruby
# Smart defaults include dependencies and descriptions automatically
TaskDecomposition.to_baml(indent_size: 4)
# Disable features if needed:
TaskDecomposition.to_baml(include_descriptions: false)
```

## ✅ Completed Features

- ✅ `T::Struct` → `class Name { ... }` with field descriptions
- ✅ `T::Enum` → `enum Name { ... }` with value descriptions
- ✅ Automatic dependency resolution and ordering
- ✅ Smart defaults (descriptions and dependencies enabled)
- ✅ Full type safety with Sorbet type checking

## Future Enhancements (Optional)

- `T.type_alias` → `type Name = ...`
- Custom naming strategies (snake_case ↔ camelCase)
- Self-referential type handling
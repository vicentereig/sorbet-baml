---
layout: doc
title: "Getting Started"
description: "Learn how to install and use sorbet-baml to convert your Sorbet types to BAML for efficient LLM prompting."
---

# Getting Started

## Prerequisites

- Ruby 3.2+
- Sorbet installed in your project
- Basic familiarity with T::Struct

## Quick Start

### 1. Define your autonomous workflow types

```ruby
# Define complex LLM workflow types for research agents
class TaskType < T::Enum
  enums do
    # Literature review and information gathering
    Research = new('research')
    # Combining multiple sources into coherent insights
    Synthesis = new('synthesis')
  end
end

class ResearchTask < T::Struct
  # Clear description of the research objective
  const :objective, String
  # Type of research task to be performed
  const :task_type, TaskType
  # Strategic priority ranking (1-5 scale)
  const :priority, Integer
end
```

### 2. Convert to BAML

```ruby
require 'sorbet-baml'

# Ruby-idiomatic API (recommended)
ResearchTask.to_baml

# Legacy API (still supported)  
baml = SorbetBaml.from_struct(ResearchTask)
puts baml
```

**Generated BAML:**
```baml
enum TaskType {
  "research" @description("Literature review and information gathering")
  "synthesis" @description("Combining multiple sources into coherent insights")
}

class ResearchTask {
  objective string @description("Clear description of the research objective")
  task_type TaskType @description("Type of research task to be performed")
  priority int @description("Strategic priority ranking (1-5 scale)")
}
```

### 3. Field descriptions are included by default

The smart defaults automatically extract field descriptions from your comments:

```ruby
class ResearchFindings < T::Struct
  # Detailed analysis results from the research
  const :findings, String
  
  # Key actionable insights extracted from findings
  const :key_insights, T::Array[String]
  
  # Confidence level in the research quality (1-10)
  const :confidence_score, Integer
end

# Generate BAML (descriptions included by default!)
ResearchFindings.to_baml
```

**Generated BAML with descriptions:**
```baml
class ResearchFindings {
  findings string @description("Detailed analysis results from the research")
  key_insights string[] @description("Key actionable insights extracted from findings")
  confidence_score int @description("Confidence level in the research quality (1-10)")
}
```

### 4. Use with autonomous research agents

Include the BAML definition in your agent prompts:

```ruby
baml = ResearchTask.to_baml
prompt = <<~PROMPT
  You are an autonomous research agent. Analyze the topic "AI in Healthcare" and break it down into strategic research tasks.
  
  Schema for your output:
  #{baml}
  
  Provide a comprehensive task decomposition in JSON format.
PROMPT

# Use with OpenAI, Anthropic, or any LLM provider
response = llm_client.chat(prompt)
result = JSON.parse(response.content)
```

## Next Steps

- [Type Mapping Reference](./type-mapping.md)
- [Advanced Usage](./advanced-usage.md)
- [Troubleshooting](./troubleshooting.md)
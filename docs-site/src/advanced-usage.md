---
layout: doc
title: "Advanced Usage"
description: "Advanced features including dependency management, field descriptions, custom formatting, and complex type scenarios."
---

# Advanced Usage

## Ruby-Idiomatic API

The gem automatically extends all T::Struct and T::Enum classes with conversion methods:

```ruby
# Define complex autonomous research workflow types
class ResearchAgent < T::Struct
  # Agent's specialized domain of expertise
  const :domain_expertise, String
  # Current confidence level in assigned research
  const :confidence_level, Integer
end

# Ruby-idiomatic - just call the method!
ResearchAgent.to_baml
ResearchAgent.baml_type_definition  # Same as to_baml
```

## Automatic Dependency Management

The most powerful feature is automatic dependency resolution:

```ruby
# Autonomous research workflow with complex dependencies
class TaskType < T::Enum
  enums do
    # Literature review and information gathering
    Research = new('research')
    # Combining multiple sources into coherent insights
    Synthesis = new('synthesis')
  end
end

class ResearchSubtask < T::Struct
  # Clear description of the research objective
  const :objective, String
  # Type of research task to be performed
  const :task_type, TaskType
end

class ResearchPlan < T::Struct
  # Main research topic being investigated
  const :research_topic, String
  # Collection of research subtasks
  const :subtasks, T::Array[ResearchSubtask]
end

# Dependencies included automatically with smart defaults!
ResearchPlan.to_baml
```

**Generated BAML (with correct ordering and descriptions):**
```baml
enum TaskType {
  "research" @description("Literature review and information gathering")
  "synthesis" @description("Combining multiple sources into coherent insights")
}

class ResearchSubtask {
  objective string @description("Clear description of the research objective")
  task_type TaskType @description("Type of research task to be performed")
}

class ResearchPlan {
  research_topic string @description("Main research topic being investigated")
  subtasks ResearchSubtask[] @description("Collection of research subtasks")
}
```

## Converting Multiple Types

### Manual Collection

```ruby
# Convert multiple autonomous research types manually
types = [TaskType, ResearchSubtask, ResearchPlan]
baml_output = types.map(&:to_baml).join("\n\n")
```

### Legacy API (still supported)

```ruby
# Legacy API for multiple structs (no smart defaults)
SorbetBaml.from_structs([TaskType, ResearchSubtask, ResearchPlan])

# Legacy API for single struct (no smart defaults)
SorbetBaml.from_struct(ResearchPlan)
```

## Advanced Type Examples

### Complex Autonomous Research Workflows

```ruby
class ConfidenceLevel < T::Enum
  enums do
    # Low confidence, requires further verification
    Low = new('low')
    # Medium confidence, reasonably supported by evidence
    Medium = new('medium')
    # High confidence, strongly supported by multiple sources
    High = new('high')
  end
end

class ResearchFindings < T::Struct
  # Detailed research findings and analysis
  const :findings, String
  # Key actionable insights extracted
  const :key_insights, T::Array[String]
  # Confidence score for findings (1-10 scale)
  const :confidence_score, Integer
end

class ResearchSynthesis < T::Struct
  # Unique identifier for the research synthesis
  const :id, String
  # Assessment of evidence quality
  const :evidence_quality, ConfidenceLevel
  # Collection of research findings
  const :findings_collection, T::Array[ResearchFindings]
  # Agent coordination metadata
  const :agent_metadata, T::Hash[String, T.any(String, Integer, Float)]
  # Optional peer review notes
  const :peer_review, T.nilable(String)
end

# Generate complete type definitions
[ConfidenceLevel, ResearchFindings, ResearchSynthesis].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum ConfidenceLevel {
  "low" @description("Low confidence, requires further verification")
  "medium" @description("Medium confidence, reasonably supported by evidence")
  "high" @description("High confidence, strongly supported by multiple sources")
}

class ResearchFindings {
  findings string @description("Detailed research findings and analysis")
  key_insights string[] @description("Key actionable insights extracted")
  confidence_score int @description("Confidence score for findings (1-10 scale)")
}

class ResearchSynthesis {
  id string @description("Unique identifier for the research synthesis")
  evidence_quality ConfidenceLevel @description("Assessment of evidence quality")
  findings_collection ResearchFindings[] @description("Collection of research findings")
  agent_metadata map<string, string | int | float> @description("Agent coordination metadata")
  peer_review string? @description("Optional peer review notes")
}
```

### Self-Referential Types

```ruby
class Category < T::Struct
  const :name, String
  const :parent, T.nilable(Category)
  const :children, T::Array[Category]
end

Category.to_baml
```

**Generated BAML:**
```baml
class Category {
  name string
  parent Category?
  children Category[]
}
```

## Tool Definitions

Generate BAML tool specifications for agentic workflows, function calling, and structured LLM interactions:

### T::Struct-based Tools

```ruby
# Define tool parameter structures for agent interactions
class SearchTool < T::Struct
  # The search query to execute
  const :query, String
  # Maximum number of results to return
  const :limit, T.nilable(Integer)
  # Optional filter criteria for search results
  const :filters, T::Hash[String, String]
end

class FileWriteTool < T::Struct
  # Path where the file should be written
  const :file_path, String
  # Content to write to the file
  const :content, String
  # Whether to overwrite existing file
  const :overwrite, T::Boolean
end

# Generate BAML tool definitions
SearchTool.to_baml_tool
FileWriteTool.to_baml_tool

# Module API also available
SorbetBaml.from_tool(SearchTool)
```

**Generated BAML Tool Specifications:**
```baml
class SearchTool {
  query string @description("The search query to execute")
  limit int? @description("Maximum number of results to return")
  filters map<string, string> @description("Optional filter criteria for search results")
}

class FileWriteTool {
  file_path string @description("Path where the file should be written")
  content string @description("Content to write to the file")
  overwrite bool @description("Whether to overwrite existing file")
}
```

### DSPy-style Tools (Optional)

When `dspy.rb` is available, automatically convert DSPy tools with rich metadata:

```ruby
class CalculatorTool < DSPy::Tools::Base
  extend T::Sig
  
  tool_name 'calculator'
  tool_description 'Performs basic arithmetic operations with error handling'

  sig { params(operation: String, num1: Float, num2: Float).returns(T.any(Float, String)) }
  def call(operation:, num1:, num2:)
    case operation.downcase
    when 'add' then num1 + num2
    when 'subtract' then num1 - num2
    when 'multiply' then num1 * num2
    when 'divide'
      return "Error: Cannot divide by zero" if num2 == 0
      num1 / num2
    else
      "Error: Unknown operation"
    end
  end
end

# Automatic extraction of tool metadata and parameter types
CalculatorTool.to_baml
# =>
# // Performs basic arithmetic operations with error handling
# class calculator {
#   operation string @description("Parameter operation")
#   num1 float @description("Parameter num1")
#   num2 float @description("Parameter num2")
# }
```

### Tool Collections for Agentic Workflows

```ruby
# Define a complete set of tools for a research agent
RESEARCH_TOOLS = [
  SearchTool,
  FileWriteTool,
  CalculatorTool
].freeze

# Generate complete tool specifications
tool_specs = RESEARCH_TOOLS.map(&:to_baml_tool).join("\n\n")

# Use in agent prompts
def build_agent_prompt(task, tools_baml)
  <<~PROMPT
    You are a research agent with access to these tools:
    
    #{tools_baml}
    
    Task: #{task}
    
    Use the appropriate tools to complete this task efficiently.
  PROMPT
end

prompt = build_agent_prompt("Research AI trends", tool_specs)
```

### Function Calling Integration

Perfect for modern LLM function calling APIs:

```ruby
# OpenAI function calling with BAML tools
tools = [SearchTool, FileWriteTool].map do |tool_class|
  {
    type: "function",
    function: {
      name: tool_class.name.downcase,
      description: "#{tool_class.name} functionality",
      parameters: tool_class.to_baml_tool
    }
  }
end

response = openai_client.chat(
  model: "gpt-4",
  messages: messages,
  tools: tools,
  tool_choice: "auto"
)
```

## Configuration Options

### Custom Indentation

```ruby
User.to_baml(indent_size: 4)
```

**Generated BAML:**
```baml
class User {
    name string
    age int
}
```

### Field Descriptions (Included by Default)

Extract documentation from Ruby comments to provide crucial LLM context for autonomous agents:

```ruby
class AgentCapabilities < T::Struct
  # Specialized domain knowledge for research tasks
  const :domain_expertise, String
  
  # Maximum concurrent research tasks the agent can handle
  const :task_capacity, Integer
  
  # Current workload as percentage of total capacity (0-100)
  const :current_workload, Integer
  
  # List of research methodologies the agent can employ
  const :research_methods, T::Array[String]
end

# Field descriptions included by default!
AgentCapabilities.to_baml
```

**Generated BAML with descriptions:**
```baml
class AgentCapabilities {
  domain_expertise string @description("Specialized domain knowledge for research tasks")
  task_capacity int @description("Maximum concurrent research tasks the agent can handle")
  current_workload int @description("Current workload as percentage of total capacity (0-100)")
  research_methods string[] @description("List of research methodologies the agent can employ")
}
```

### Combining Options

```ruby
# Smart defaults: dependencies and descriptions already included!
ResearchSynthesis.to_baml(indent_size: 4)

# Or disable features if needed for specific use cases
ResearchSynthesis.to_baml(
  include_dependencies: false,
  include_descriptions: false,
  indent_size: 4
)
```

## File Generation

### Single File Output

```ruby
# Generate and write autonomous research schema to file
baml_content = ResearchSynthesis.to_baml
File.write("schemas/research_workflow.baml", baml_content)
```

### Multiple Files

```ruby
# Generate separate files for each research workflow type
[ConfidenceLevel, ResearchFindings, ResearchSynthesis].each do |type|
  filename = type.name.downcase.gsub('::', '_')
  File.write("schemas/#{filename}.baml", type.to_baml)
end
```

### Build Process Integration

```ruby
# Rakefile
desc "Generate BAML schemas for autonomous agents"
task :generate_baml do
  require 'sorbet-baml'
  require_relative 'lib/research_types'
  
  # Your autonomous research workflow types
  types = [TaskType, ResearchSubtask, ResearchFindings, ResearchSynthesis]
  baml_content = types.map(&:to_baml).join("\n\n")
  
  File.write("schemas/research_agents.baml", baml_content)
  puts "Generated BAML schemas for research agents in schemas/research_agents.baml"
end
```

## LLM Integration Patterns

### With OpenAI Structured Outputs

```ruby
require 'openai'
require 'sorbet-baml'

# Define your response format
class AnalysisResult < T::Struct
  const :sentiment, String
  const :confidence, Float
  const :key_phrases, T::Array[String]
  const :metadata, T::Hash[String, String]
end

# Generate schema for LLM
schema = AnalysisResult.to_baml

client = OpenAI::Client.new
response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      {
        role: "system",
        content: "Analyze text and respond with data matching this BAML schema:\n\n#{schema}"
      },
      {
        role: "user", 
        content: "Analyze: 'I love this new product!'"
      }
    ]
  }
)
```

### With Anthropic Claude

```ruby
require 'anthropic'
require 'sorbet-baml'

schema = UserProfile.to_baml(include_dependencies: true)

client = Anthropic::Client.new
response = client.messages(
  model: "claude-3-5-sonnet-20241022",
  max_tokens: 1000,
  messages: [
    {
      role: "user",
      content: "Generate a realistic user profile matching this schema:\n\n#{schema}"
    }
  ]
)
```

### With DSPy.rb Integration

```ruby
require 'dspy'
require 'sorbet-baml'

# Your T::Struct automatically works with DSPy signatures
class UserAnalysis < DSPy::Signature
  input { const :user_data, String }
  output { const :analysis, AnalysisResult }  # Uses your T::Struct
end

# The BAML schema is automatically generated for LLM prompts
predictor = DSPy::Predict.new(UserAnalysis)
result = predictor.call(user_data: "John, 25, loves hiking")
```

### Prompt Engineering

```ruby
# Template for complex prompts
def build_analysis_prompt(data, schema)
  <<~PROMPT
    You are a data analyst. Analyze the following data and return results 
    in the exact format specified by this BAML schema:

    #{schema}

    Data to analyze:
    #{data}

    Requirements:
    - Follow the schema exactly
    - Provide confidence scores between 0.0 and 1.0
    - Extract meaningful insights
  PROMPT
end

schema = AnalysisResult.to_baml
prompt = build_analysis_prompt(user_input, schema)
```

## Rails Integration

### Model Integration

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Your ActiveRecord model...
  
  # Add Sorbet types for API schemas
  class UserAPI < T::Struct
    const :id, Integer
    const :name, String
    const :email, String
    const :created_at, String
  end
  
  def to_api_schema
    UserAPI.to_baml
  end
end

# Usage in controllers
class UsersController < ApplicationController
  def schema
    render json: { schema: User::UserAPI.to_baml }
  end
end
```

### API Documentation

```ruby
# Generate API docs automatically
class ApiDocsGenerator
  API_TYPES = [
    User::UserAPI,
    Order::OrderAPI,
    Product::ProductAPI
  ].freeze
  
  def self.generate
    schema = API_TYPES.map(&:to_baml).join("\n\n")
    File.write("docs/api_schema.baml", schema)
  end
end
```

## Performance Considerations

### Caching Generated BAML

```ruby
class CachedTypeConverter
  def self.to_baml(type)
    @cache ||= {}
    @cache[type] ||= type.to_baml
  end
end

# Use in production for frequently accessed types
schema = CachedTypeConverter.to_baml(User)
```

### Lazy Loading

```ruby
# Only generate BAML when needed (smart defaults apply)
class ApiResponse
  def schema
    @schema ||= self.class.to_baml
  end
end
```
# Getting Started

## Prerequisites

- Ruby 3.1+
- Sorbet installed in your project
- Basic familiarity with T::Struct

## Quick Start

### 1. Define your Sorbet types

```ruby
class User < T::Struct
  const :id, Integer
  const :name, String
  const :email, T.nilable(String)
end
```

### 2. Convert to BAML

```ruby
require 'sorbet-baml'

baml = SorbetBaml.from_struct(User)
puts baml
# Output:
# class User {
#   id int
#   name string
#   email string?
# }
```

### 3. Use with your LLM

Include the BAML definition in your prompt:

```ruby
prompt = <<~PROMPT
  Generate sample data matching this schema:
  
  #{baml}
  
  Return 3 examples.
PROMPT
```

## Next Steps

- [Type Mapping Reference](./type-mapping.md)
- [Advanced Usage](./advanced-usage.md)
- [Troubleshooting](./troubleshooting.md)
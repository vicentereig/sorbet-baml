# Getting Started

## Prerequisites

- Ruby 3.2+
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

# Ruby-idiomatic API (recommended)
User.to_baml

# Legacy API (still supported)  
baml = SorbetBaml.from_struct(User)
puts baml
```

**Generated BAML:**
```baml
class User {
  id int
  name string
  email string?
}
```

### 3. Add field descriptions (optional)

Document your fields with comments for better LLM understanding:

```ruby
class User < T::Struct
  # Unique identifier for the user account
  const :id, Integer
  
  # User's display name, visible to other users
  const :name, String
  
  # Optional email for notifications and login
  const :email, T.nilable(String)
end

# Generate BAML (descriptions included by default!)
User.to_baml
```

**Generated BAML with descriptions:**
```baml
class User {
  id int @description("Unique identifier for the user account")
  name string @description("User's display name, visible to other users")
  email string? @description("Optional email for notifications and login")
}
```

### 4. Use with your LLM

Include the BAML definition in your prompt:

```ruby
baml = User.to_baml
prompt = <<~PROMPT
  Generate sample data matching this schema:
  
  #{baml}
  
  Return 3 realistic examples.
PROMPT
```

## Next Steps

- [Type Mapping Reference](./type-mapping.md)
- [Advanced Usage](./advanced-usage.md)
- [Troubleshooting](./troubleshooting.md)
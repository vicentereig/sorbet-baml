# sorbet-baml Documentation

Developer documentation for the sorbet-baml gem.

## For Users

If you want to use this gem in your project:

1. **[Getting Started](./getting-started.md)** - Installation and basic usage
2. **[Type Mapping Reference](./type-mapping.md)** - Complete type conversion table
3. **[Advanced Usage](./advanced-usage.md)** - Complex scenarios and integrations
4. **[Troubleshooting](./troubleshooting.md)** - Common issues and solutions

## For Contributors

If you want to contribute to this gem:

1. **[Architecture](./architecture.md)** - How the gem is structured
2. **[Adding Type Support](./adding-types.md)** - How to add new type mappings
3. **[Testing Guide](./testing.md)** - How to write and run tests

## Quick Example

```ruby
# Define a Sorbet struct
class User < T::Struct
  const :name, String
  const :age, Integer
  const :email, T.nilable(String)
end

# Convert to BAML
require 'sorbet-baml'
puts SorbetBaml.from_struct(User)

# Output:
# class User {
#   name string
#   age int
#   email string?
# }
```

## Design Goals

1. **Simplicity** - Easy to understand and use
2. **Accuracy** - Correct type mappings
3. **Efficiency** - Minimal token usage in output
4. **Compatibility** - Works with existing Sorbet codebases

## What This Is Not

- Not a BAML runtime or executor
- Not a JSON Schema generator (use sorbet-schema for that)
- Not a Sorbet type checker
- Not a serialization library

## Why BAML?

BAML (Boundary AI Markup Language) provides a concise way to define types for LLM consumption. Compared to JSON Schema:

- ~60% fewer tokens
- More readable
- Better LLM comprehension
- Simpler syntax

Perfect for prompt engineering and structured output generation.
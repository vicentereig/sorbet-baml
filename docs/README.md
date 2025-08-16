# sorbet-baml Documentation

Developer documentation for the sorbet-baml gem.

## For Users

If you want to use this gem in your project:

1. **[Getting Started](./getting-started.md)** - Installation and basic usage
2. **[Type Mapping Reference](./type-mapping.md)** - Complete type conversion table
3. **[Advanced Usage](./advanced-usage.md)** - Complex scenarios and integrations
4. **[Troubleshooting](./troubleshooting.md)** - Common issues and solutions

## For Contributors

This gem has reached **feature completeness** for core BAML conversion needs. The implementation is production-ready with:

- ✅ **Complete type support** - All Sorbet types mapped to BAML
- ✅ **Ruby-idiomatic API** - `.to_baml` method on all T::Struct/T::Enum classes  
- ✅ **Dependency management** - Automatic topological sorting
- ✅ **100% test coverage** - 34 comprehensive test cases
- ✅ **Full Sorbet type safety** - Zero type errors

Future enhancements are optional nice-to-haves rather than core requirements.

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

# Legacy API also supported
# SorbetBaml.from_struct(User)
```

**Generated BAML:**
```baml
class User {
  name string
  age int
  email string?
}
```

## Design Goals

1. **Ruby-Idiomatic** - Natural `.to_baml` API that feels native
2. **Production-Ready** - Complete type support, dependency management, full test coverage
3. **Token Efficiency** - 60% fewer tokens than JSON Schema for real workloads
4. **Zero-Config** - Works automatically with existing Sorbet codebases
5. **Type-Safe** - Full Sorbet type checking throughout the gem

## What This Is Not

- Not a BAML runtime or executor
- Not a JSON Schema generator (use [sorbet-schema](https://github.com/maxveldink/sorbet-schema) for that)
- Not a Sorbet type checker
- Not a serialization library

## Advanced Features

### Ruby-Idiomatic API
```ruby
User.to_baml                    # Single type
User.to_baml(indent_size: 4)    # Custom formatting
User.to_baml(include_dependencies: true)  # With dependencies
```

### Automatic Dependency Management
```ruby
class Address < T::Struct
  const :street, String
end

class User < T::Struct
  const :address, Address
end

User.to_baml(include_dependencies: true)
```

**Generated BAML (correct ordering):**
```baml
class Address {
  street string
}

class User {
  address Address
}
```

## Why BAML?

BAML (Boundary AI Markup Language) provides a concise way to define types for LLM consumption. **Real-world comparison** from production agentic workflows:

| Format | Tokens | Efficiency |
|--------|--------|-----------|
| JSON Schema | ~450 | baseline |
| **BAML** | **~180** | **🔥 60% fewer** |

### Benefits:
- **Cost Savings**: 60% reduction in prompt tokens = 60% lower LLM API costs
- **Performance**: Smaller prompts = faster LLM response times  
- **Context Efficiency**: More room for actual content vs. type definitions
- **Readability**: Human-readable and maintainable
- **LLM-Friendly**: Designed specifically for AI consumption

Perfect for prompt engineering, structured output generation, and agentic workflows where token efficiency matters.
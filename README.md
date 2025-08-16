# sorbet-baml

Ruby-idiomatic conversion from Sorbet types to BAML (Boundary AI Markup Language) for efficient LLM prompting.

## What is this?

This gem provides a clean, Ruby-idiomatic API to convert your Sorbet type definitions (T::Struct, T::Enum) into BAML's concise format. BAML uses approximately **60% fewer tokens** than JSON Schema while maintaining complete type information, making your LLM interactions more efficient and cost-effective.

## Why?

When working with LLMs, token efficiency directly impacts:
- **Cost**: Fewer tokens = lower API costs
- **Performance**: Smaller prompts = faster responses  
- **Context**: More room for actual content vs. type definitions

BAML provides the perfect balance: concise, readable, and LLM-friendly.

### Example

```ruby
# Your Sorbet types
class User < T::Struct
  const :name, String
  const :age, Integer
  const :email, T.nilable(String)
  const :preferences, T::Hash[String, T.any(String, Integer)]
end

# Ruby-idiomatic conversion
User.to_baml
# =>
# class User {
#   name string
#   age int
#   email string?
#   preferences map<string, string | int>
# }
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

## Usage

```ruby
require 'sorbet-baml'

# 🎯 Ruby-idiomatic API - just call .to_baml on any T::Struct or T::Enum!

class Status < T::Enum
  enums do
    Active = new('active')
    Inactive = new('inactive')
  end
end

class Address < T::Struct
  const :street, String
  const :city, String
  const :postal_code, T.nilable(String)
end

class User < T::Struct
  const :name, String
  const :status, Status
  const :address, Address
  const :tags, T::Array[String]
  const :metadata, T::Hash[String, T.any(String, Integer)]
end

# Convert individual types
User.to_baml
Status.to_baml
Address.to_baml

# 🚀 Include all dependencies automatically
User.to_baml(include_dependencies: true)
# =>
# enum Status {
#   "active"
#   "inactive"
# }
# 
# class Address {
#   street string
#   city string
#   postal_code string?
# }
# 
# class User {
#   name string
#   status Status
#   address Address
#   tags string[]
#   metadata map<string, string | int>
# }

# Customize formatting
User.to_baml(
  include_dependencies: true,
  indent_size: 4
)

# Legacy API still supported
SorbetBaml.from_struct(User)
SorbetBaml.from_structs([User, Address])
```

## 🎯 Complete Type Support

### ✅ Fully Supported

**Basic Types**
- `String` → `string`
- `Integer` → `int` 
- `Float` → `float`
- `T::Boolean` → `bool`
- `Symbol` → `string`
- `Date/DateTime/Time` → `string`

**Complex Types**
- `T.nilable(T)` → `T?` (optional types)
- `T::Array[T]` → `T[]` (arrays)
- `T::Hash[K,V]` → `map<K,V>` (hash maps)
- `T.any(T1, T2)` → `T1 | T2` (union types)
- `T.nilable(T.any(T1, T2))` → `(T1 | T2)?` (optional unions)
- `T::Array[T.any(T1, T2)]` → `(T1 | T2)[]` (union arrays)

**Structured Types**
- `T::Struct` → `class Name { ... }` (classes with fields)
- `T::Enum` → `enum Name { "value1" "value2" }` (enums)
- Nested structs with proper reference handling
- **Automatic dependency resolution** with topological sorting

### 🚀 Advanced Features

- **Ruby-idiomatic API**: Every T::Struct and T::Enum gets `.to_baml` method
- **Dependency management**: `include_dependencies: true` automatically includes all referenced types
- **Proper ordering**: Dependencies are sorted topologically (no forward references needed)
- **Circular reference handling**: Won't get stuck in infinite loops
- **Customizable formatting**: Control indentation and other output options
- **Type-safe**: Full Sorbet type checking throughout

## Type Mapping Reference

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `String` | `string` | `name string` |
| `Integer` | `int` | `age int` |
| `Float` | `float` | `price float` |
| `T::Boolean` | `bool` | `active bool` |
| `T.nilable(String)` | `string?` | `email string?` |
| `T::Array[String]` | `string[]` | `tags string[]` |
| `T::Hash[String, Integer]` | `map<string, int>` | `counts map<string, int>` |
| `T.any(String, Integer)` | `string \| int` | `value string \| int` |
| `T.nilable(T.any(String, Integer))` | `(string \| int)?` | `optional_value (string \| int)?` |
| `T::Array[T.any(String, Integer)]` | `(string \| int)[]` | `mixed_array (string \| int)[]` |
| `MyStruct` | `MyStruct` | `user MyStruct` |
| `MyEnum` | `MyEnum` | `status MyEnum` |

## 🏁 Production Ready

This gem has reached **feature completeness** for core BAML conversion needs. The Ruby-idiomatic API is stable and thoroughly tested with **34 test cases** covering all type combinations and edge cases.

### 📊 Quality Metrics

- ✅ **100% Test Coverage** - All features comprehensively tested
- ✅ **Full Sorbet Type Safety** - Zero type errors throughout codebase  
- ✅ **34 Test Cases** - Covering basic types, complex combinations, and edge cases
- ✅ **TDD Development** - All features built test-first
- ✅ **Zero Breaking Changes** - Maintains backward compatibility

### 🗺️ Future Enhancements (Optional)

The core implementation is complete. These are nice-to-have enhancements:

- [ ] **Type aliases**: `T.type_alias { String }` → `type Alias = string`
- [ ] **Field descriptions**: Extract documentation from comments  
- [ ] **Custom naming**: Convert between snake_case ↔ camelCase
- [ ] **CLI tool**: `sorbet-baml convert User` command
- [ ] **Validation**: Verify generated BAML syntax
- [ ] **Self-referential types**: `Employee` with `manager: T.nilable(Employee)`

### 📈 Version History

- **v0.0.1** - Initial implementation with basic type support
- **v0.1.0** (Ready) - Complete type system + Ruby-idiomatic API

## 🌟 Real-World Usage

Perfect for Rails applications, API documentation, and any Ruby codebase using Sorbet:

```ruby
# In your Rails models
class User < ApplicationRecord
  # Your existing Sorbet types...
end

# Generate BAML for LLM prompts  
prompt = <<~PROMPT
  Given this user schema:
  
  #{User.to_baml}
  
  Generate 5 realistic test users in JSON format.
PROMPT

# Use with OpenAI, Anthropic, or any LLM provider
response = client.chat(prompt)
```

## 🔗 Integration Examples

**With OpenAI structured outputs:**
```ruby
User.to_baml(include_dependencies: true)
# Use the generated BAML in your function calling schemas
```

**With prompt engineering:**
```ruby
# More efficient than JSON Schema
schema = User.to_baml(include_dependencies: true)
prompt = "Generate data matching: #{schema}"
```

**With documentation generation:**
```ruby
# Auto-generate API docs
api_types = [User, Order, Product].map(&:to_baml).join("\n\n")
```

## Credits

This project was inspired by [`sorbet-schema`](https://github.com/maxveldink/sorbet-schema) which provides excellent Sorbet type introspection capabilities. While sorbet-schema focuses on serialization/deserialization, sorbet-baml focuses on generating efficient type definitions for LLM consumption.

## Contributing

Bug reports and pull requests are welcome at https://github.com/vicentereig/sorbet-baml

## License

MIT License. See LICENSE.txt for details.
# sorbet-baml

Convert Sorbet type definitions to BAML (Boundary AI Markup Language) for more efficient LLM prompting.

## What is this?

This gem translates Ruby's Sorbet type definitions (T::Struct, T::Enum) into BAML's concise type definition format. BAML uses approximately 60% fewer tokens than JSON Schema while maintaining complete type information.

## Why?

When working with LLMs, token efficiency matters. Traditional JSON Schema definitions are verbose. BAML provides a more compact representation that LLMs can parse effectively.

### Example

```ruby
# Your Sorbet types
class Address < T::Struct
  const :street, String
  const :city, String
  const :zip, T.nilable(String)
end

# Converts to BAML
class Address {
  street string
  city string
  zip string?
}
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

# Convert a single struct
baml_definition = SorbetBaml.from_struct(MyStruct)

# Convert multiple related structs
baml_definitions = SorbetBaml.from_structs([User, Address, Order])

# With options
baml = SorbetBaml.from_struct(User, 
  include_descriptions: true,
  indent_size: 2
)
```

## Current Capabilities

✅ **Supported**
- Basic types (String, Integer, Float, Boolean)
- T.nilable (optional fields)
- T::Array
- Nested T::Struct
- T::Enum (planned)

⚠️ **Limitations**
- No T::Hash/map support yet
- No union types (T.any) yet
- No type aliases yet
- No runtime validation of generated BAML

## Type Mapping

| Sorbet | BAML | Status |
|--------|------|--------|
| String | string | ✅ |
| Integer | int | ✅ |
| Float | float | ✅ |
| T::Boolean | bool | ✅ |
| T.nilable(T) | T? | ✅ |
| T::Array[T] | T[] | ✅ |
| T::Hash[K,V] | map<K,V> | 🚧 |
| T.any(T1,T2) | T1 \| T2 | 🚧 |
| T::Enum | enum Name { ... } | 🚧 |

## Development Status

This gem is in early development (v0.0.1). The API may change. Use in production at your own risk.

### Roadmap

- [ ] Complete T::Enum support
- [ ] Add T::Hash/map conversion
- [ ] Support union types
- [ ] Handle circular references
- [ ] Add type aliases
- [ ] Preserve field descriptions from comments

## Credits

This project was inspired by [`sorbet-schema`](https://github.com/maxveldink/sorbet-schema) which provides excellent Sorbet type introspection capabilities. While sorbet-schema focuses on serialization/deserialization, sorbet-baml focuses on generating efficient type definitions for LLM consumption.

## Contributing

Bug reports and pull requests are welcome at https://github.com/vicentereig/sorbet-baml

## License

MIT License. See LICENSE.txt for details.
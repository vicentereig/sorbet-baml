# Type Mapping Reference

Complete mapping between Sorbet types and BAML output.

## Basic Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `String` | `string` | `name string` |
| `Integer` | `int` | `age int` |
| `Float` | `float` | `price float` |
| `T::Boolean` | `bool` | `active bool` |
| `NilClass` | `null` | `null` |
| `Symbol` | `string` | `status string` |

## Optional Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T.nilable(String)` | `string?` | `email string?` |
| `T.nilable(Integer)` | `int?` | `age int?` |

## Collection Types

| Sorbet Type | BAML Output | Example |
|-------------|-------------|---------|
| `T::Array[String]` | `string[]` | `tags string[]` |
| `T::Array[T::Struct]` | `StructName[]` | `addresses Address[]` |

## Nested Structures

```ruby
# Input
class Address < T::Struct
  const :street, String
  const :city, String
end

class User < T::Struct
  const :name, String
  const :address, Address
end

# Output
class Address {
  street string
  city string
}

class User {
  name string
  address Address
}
```

## Not Yet Supported

These types will be added in future versions:

- `T::Hash[K, V]` → `map<K, V>`
- `T.any(Type1, Type2)` → `Type1 | Type2`
- `T::Enum` subclasses → `enum Name { ... }`
- `T.type_alias` → `type Name = ...`
- `T::Set[T]` → `T[]` (with uniqueness note)
- `T::Range[T]` → Will need special handling
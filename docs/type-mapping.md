# Type Mapping Reference

Complete mapping between Sorbet types and BAML output. All listed types are **fully supported**.

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

### T::Struct to BAML Classes

```ruby
class Address < T::Struct
  const :street, String
  const :city, String
  const :postal_code, T.nilable(String)
end

class User < T::Struct
  const :name, String
  const :age, Integer
  const :address, Address
  const :tags, T::Array[String]
end
```

```ruby
User.to_baml
```

**Generated BAML:**
```baml
class User {
  name string
  age int
  address Address
  tags string[]
}
```

### T::Enum to BAML Enums

```ruby
class Status < T::Enum
  enums do
    Active = new('active')
    Inactive = new('inactive')
    Pending = new('pending')
  end
end

class User < T::Struct
  const :name, String
  const :status, Status
end
```

```ruby
[Status, User].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum Status {
  "active"
  "inactive"
  "pending"
}

class User {
  name string
  status Status
}
```

### Complex Real-World Example

```ruby
class Priority < T::Enum
  enums do
    Low = new('low')
    Medium = new('medium')
    High = new('high')
  end
end

class Task < T::Struct
  const :title, String
  const :description, T.nilable(String)
  const :priority, Priority
  const :tags, T::Array[String]
  const :metadata, T::Hash[String, T.any(String, Integer)]
  const :subtasks, T::Array[Task]
end
```

```ruby
[Priority, Task].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum Priority {
  "low"
  "medium"
  "high"
}

class Task {
  title string
  description string?
  priority Priority
  tags string[]
  metadata map<string, string | int>
  subtasks Task[]
}
```

## Advanced Features

### Dependency Management

```ruby
# Dependencies automatically included with smart defaults
User.to_baml
# Outputs Address, then User in correct order
```

### Custom Formatting

```ruby
# Smart defaults include dependencies automatically
User.to_baml(indent_size: 4)
```

## Future Enhancements (Optional)

These are nice-to-have features for future versions:

- `T.type_alias` → `type Name = ...`
- Field descriptions from comments
- Custom naming strategies (snake_case ↔ camelCase)
- Self-referential type handling
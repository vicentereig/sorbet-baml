# Troubleshooting

## Common Issues

### "undefined method `props' for Class"

**Problem**: The class you're trying to convert is not a T::Struct.

**Solution**: Ensure your class inherits from `T::Struct`:

```ruby
# ❌ Wrong
class User
  attr_reader :name
end

# ✅ Correct
class User < T::Struct
  const :name, String
end

# Generate BAML
User.to_baml
```

**Generated BAML:**
```baml
class User {
  name string
}
```

### Empty output

**Problem**: The struct has no properties defined.

**Solution**: Define at least one property using `const` or `prop`:

```ruby
class User < T::Struct
  const :name, String  # Add properties
  const :age, Integer
end

User.to_baml
```

**Generated BAML:**
```baml
class User {
  name string
  age int
}
```

### Self-referential types work fine

**Problem**: You think self-referential types aren't supported.

**Solution**: They actually work perfectly! Self-referential types are fully supported:

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

## Type-Specific Issues

### Arrays not converting correctly

Ensure you're using the Sorbet array syntax:

```ruby
# ❌ Wrong
class User < T::Struct
  const :items, Array  # Generic Array won't work
end

# ✅ Correct
class User < T::Struct
  const :items, T::Array[String]
end

User.to_baml
```

**Generated BAML:**
```baml
class User {
  items string[]
}
```

### Optional fields showing as required

Make sure to use `T.nilable`:

```ruby
# ❌ Wrong - will be required
class User < T::Struct
  const :email, String
end

# ✅ Correct - will be optional
class User < T::Struct
  const :email, T.nilable(String)
end

User.to_baml
```

**Generated BAML:**
```baml
class User {
  email string?
}
```

### Union types not working

Ensure you're using `T.any` for union types:

```ruby
# ❌ Wrong
class Config < T::Struct
  const :value, String || Integer  # Ruby OR, not Sorbet union
end

# ✅ Correct
class Config < T::Struct
  const :value, T.any(String, Integer)
end

Config.to_baml
```

**Generated BAML:**
```baml
class Config {
  value string | int
}
```

### Hash types not mapping correctly

Use the full `T::Hash[K, V]` syntax:

```ruby
# ❌ Wrong
class User < T::Struct
  const :metadata, Hash  # Generic Hash won't work
end

# ✅ Correct
class User < T::Struct
  const :metadata, T::Hash[String, T.any(String, Integer)]
end

User.to_baml
```

**Generated BAML:**
```baml
class User {
  metadata map<string, string | int>
}
```

## Dependency Issues

### Missing dependencies in output

Use `include_dependencies: true` to automatically include all referenced types:

```ruby
class Address < T::Struct
  const :street, String
  const :city, String
end

class User < T::Struct
  const :name, String
  const :address, Address
end

# ❌ Only outputs User class
User.to_baml

# ✅ Outputs both Address and User in correct order
User.to_baml(include_dependencies: true)
```

**Generated BAML (with dependencies):**
```baml
class Address {
  street string
  city string
}

class User {
  name string
  address Address
}
```

### Wrong dependency order

The gem automatically handles dependency ordering using topological sorting. Dependencies always come before the types that reference them.

## Enum Issues

### Enums not converting

Ensure you're using the correct T::Enum syntax:

```ruby
# ❌ Wrong
class Status
  ACTIVE = 'active'
  INACTIVE = 'inactive'
end

# ✅ Correct
class Status < T::Enum
  enums do
    Active = new('active')
    Inactive = new('inactive')
  end
end

Status.to_baml
```

**Generated BAML:**
```baml
enum Status {
  "active"
  "inactive"
}
```

## Getting Help

1. Check the [Type Mapping Reference](./type-mapping.md) for complete type support
2. Review examples in [Getting Started](./getting-started.md) and [Advanced Usage](./advanced-usage.md)
3. File an issue at https://github.com/vicentereig/sorbet-baml/issues

## Advanced Debugging

### Inspect Sorbet type information

```ruby
# See what Sorbet sees for your struct
MyStruct.props
# => {name: String, age: Integer, ...}

# Check if a class is a T::Struct
MyStruct < T::Struct
# => true

# See enum values
MyEnum.values
# => [#<MyEnum:0x... @serialize="value1">, ...]
```

### Testing your BAML output

```ruby
# Verify the output looks correct
baml = User.to_baml(include_dependencies: true)
puts baml

# Check that all expected types are included
expected_types = ['class User', 'class Address', 'enum Status']
expected_types.all? { |type| baml.include?(type) }
# => true
```
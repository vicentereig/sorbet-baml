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
```

### Empty output

**Problem**: The struct has no properties defined.

**Solution**: Define at least one property using `const` or `prop`:

```ruby
class User < T::Struct
  const :name, String  # Add properties
end
```

### Circular dependency detected

**Problem**: Two structs reference each other creating an infinite loop.

**Solution**: This is not yet supported. Consider flattening the structure or using a different approach.

## Type-Specific Issues

### Arrays not converting correctly

Ensure you're using the Sorbet array syntax:

```ruby
# ❌ Wrong
const :items, Array

# ✅ Correct
const :items, T::Array[String]
```

### Optional fields showing as required

Make sure to use `T.nilable`:

```ruby
# ❌ Wrong - will be required
const :email, String

# ✅ Correct - will be optional
const :email, T.nilable(String)
```

## Getting Help

1. Check the [Type Mapping Reference](./type-mapping.md)
2. Review the examples in [Getting Started](./getting-started.md)
3. File an issue at https://github.com/vicentereig/sorbet-baml/issues

## Debug Mode

To see detailed conversion information:

```ruby
# Future feature - not yet implemented
SorbetBaml.debug = true
baml = SorbetBaml.from_struct(MyStruct)
```
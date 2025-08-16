# Troubleshooting

## Common Issues

### "undefined method `props' for Class"

**Problem**: The class you're trying to convert is not a T::Struct.

**Solution**: Ensure your class inherits from `T::Struct`:

```ruby
# ❌ Wrong
class ResearchAgent
  attr_reader :domain_expertise
end

# ✅ Correct
class ResearchAgent < T::Struct
  # Agent's specialized domain of expertise
  const :domain_expertise, String
end

# Generate BAML (descriptions included by default!)
ResearchAgent.to_baml
```

**Generated BAML:**
```baml
class ResearchAgent {
  domain_expertise string @description("Agent's specialized domain of expertise")
}
```

### Empty output

**Problem**: The struct has no properties defined.

**Solution**: Define at least one property using `const` or `prop`:

```ruby
class ResearchAgent < T::Struct
  # Agent's specialized domain of expertise
  const :domain_expertise, String
  # Maximum concurrent research tasks
  const :task_capacity, Integer
end

ResearchAgent.to_baml
```

**Generated BAML:**
```baml
class ResearchAgent {
  domain_expertise string @description("Agent's specialized domain of expertise")
  task_capacity int @description("Maximum concurrent research tasks")
}
```

### Self-referential types work fine

**Problem**: You think self-referential types aren't supported.

**Solution**: They actually work perfectly! Self-referential types are fully supported:

```ruby
class ResearchHierarchy < T::Struct
  # Name of the research domain or subdomain
  const :domain_name, String
  # Parent research domain for hierarchical organization
  const :parent_domain, T.nilable(ResearchHierarchy)
  # Child research subdomains
  const :subdomains, T::Array[ResearchHierarchy]
end

ResearchHierarchy.to_baml
```

**Generated BAML:**
```baml
class ResearchHierarchy {
  domain_name string @description("Name of the research domain or subdomain")
  parent_domain ResearchHierarchy? @description("Parent research domain for hierarchical organization")
  subdomains ResearchHierarchy[] @description("Child research subdomains")
}
```

## Type-Specific Issues

### Arrays not converting correctly

Ensure you're using the Sorbet array syntax:

```ruby
# ❌ Wrong
class ResearchAgent < T::Struct
  const :research_methods, Array  # Generic Array won't work
end

# ✅ Correct
class ResearchAgent < T::Struct
  # List of research methodologies the agent can employ
  const :research_methods, T::Array[String]
end

ResearchAgent.to_baml
```

**Generated BAML:**
```baml
class ResearchAgent {
  research_methods string[] @description("List of research methodologies the agent can employ")
}
```

### Optional fields showing as required

Make sure to use `T.nilable`:

```ruby
# ❌ Wrong - will be required
class ResearchAgent < T::Struct
  # Peer review notes
  const :peer_review, String
end

# ✅ Correct - will be optional
class ResearchAgent < T::Struct
  # Optional peer review notes
  const :peer_review, T.nilable(String)
end

ResearchAgent.to_baml
```

**Generated BAML:**
```baml
class ResearchAgent {
  peer_review string? @description("Optional peer review notes")
}
```

### Union types not working

Ensure you're using `T.any` for union types:

```ruby
# ❌ Wrong
class ResearchConfig < T::Struct
  const :parameter_value, String || Integer  # Ruby OR, not Sorbet union
end

# ✅ Correct
class ResearchConfig < T::Struct
  # Configuration parameter supporting multiple value types
  const :parameter_value, T.any(String, Integer)
end

ResearchConfig.to_baml
```

**Generated BAML:**
```baml
class ResearchConfig {
  parameter_value string | int @description("Configuration parameter supporting multiple value types")
}
```

### Hash types not mapping correctly

Use the full `T::Hash[K, V]` syntax:

```ruby
# ❌ Wrong
class ResearchAgent < T::Struct
  const :agent_metadata, Hash  # Generic Hash won't work
end

# ✅ Correct
class ResearchAgent < T::Struct
  # Agent coordination metadata with flexible value types
  const :agent_metadata, T::Hash[String, T.any(String, Integer)]
end

ResearchAgent.to_baml
```

**Generated BAML:**
```baml
class ResearchAgent {
  agent_metadata map<string, string | int> @description("Agent coordination metadata with flexible value types")
}
```

## Dependency Issues

### Missing dependencies in output

Dependencies are included by default! Smart defaults make this automatic:

```ruby
class TaskType < T::Enum
  enums do
    # Literature review and information gathering
    Research = new('research')
  end
end

class ResearchTask < T::Struct
  # Clear description of the research objective
  const :objective, String
  # Type of research task to be performed
  const :task_type, TaskType
end

# ✅ Smart defaults: outputs both TaskType and ResearchTask automatically
ResearchTask.to_baml

# ❌ Only if you explicitly disable dependencies
ResearchTask.to_baml(include_dependencies: false)
```

**Generated BAML (with dependencies by default):**
```baml
enum TaskType {
  "research" @description("Literature review and information gathering")
}

class ResearchTask {
  objective string @description("Clear description of the research objective")
  task_type TaskType @description("Type of research task to be performed")
}
```

### Wrong dependency order

The gem automatically handles dependency ordering using topological sorting. Dependencies always come before the types that reference them.

## Enum Issues

### Enums not converting

Ensure you're using the correct T::Enum syntax:

```ruby
# ❌ Wrong
class ResearchStatus
  ACTIVE = 'active'
  COMPLETED = 'completed'
end

# ✅ Correct
class ResearchStatus < T::Enum
  enums do
    # Research is actively in progress
    Active = new('active')
    # Research has been completed successfully
    Completed = new('completed')
  end
end

ResearchStatus.to_baml
```

**Generated BAML:**
```baml
enum ResearchStatus {
  "active" @description("Research is actively in progress")
  "completed" @description("Research has been completed successfully")
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
# Verify the output looks correct (dependencies included by default)
baml = ResearchTask.to_baml
puts baml

# Check that all expected types are included
expected_types = ['class ResearchTask', 'enum TaskType']
expected_types.all? { |type| baml.include?(type) }
# => true

# Verify descriptions are included
baml.include?('@description')
# => true
```
# Advanced Usage

## Converting Multiple Structs

When you have related structs, convert them together to maintain relationships:

```ruby
class Address < T::Struct
  const :street, String
  const :city, String
end

class Company < T::Struct
  const :name, String
  const :address, Address
end

class User < T::Struct
  const :name, String
  const :company, Company
end

# Convert all at once
baml = SorbetBaml.from_structs([Address, Company, User])
```

## Options

### Include Descriptions

```ruby
# Future feature - not yet implemented
baml = SorbetBaml.from_struct(User,
  include_descriptions: true  # Will add @description annotations
)
```

### Custom Indentation

```ruby
# Future feature - not yet implemented
baml = SorbetBaml.from_struct(User,
  indent_size: 4  # Use 4 spaces instead of 2
)
```

## Working with Existing BAML Projects

If you're already using BAML, you can generate type definitions to include in your `.baml` files:

```ruby
# Generate just the class definition
definition = SorbetBaml.from_struct(MyStruct)

# Write to a BAML file
File.write("types/my_struct.baml", definition)
```

## Integration with LLM Libraries

### With OpenAI

```ruby
require 'openai'
require 'sorbet-baml'

schema = SorbetBaml.from_struct(ResponseFormat)

response = client.chat(
  model: "gpt-4",
  messages: [{
    role: "system",
    content: "You must respond with data matching this BAML schema:\n\n#{schema}"
  }, {
    role: "user", 
    content: "Generate a sample user"
  }]
)
```

### With DSPy.rb

```ruby
# Coming soon - integration with DSPy.rb for automatic schema generation
```
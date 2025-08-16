# Advanced Usage

## Ruby-Idiomatic API

The gem automatically extends all T::Struct and T::Enum classes with conversion methods:

```ruby
class User < T::Struct
  const :name, String
  const :age, Integer
end

# Ruby-idiomatic - just call the method!
User.to_baml
User.baml_type_definition  # Same as to_baml
```

## Automatic Dependency Management

The most powerful feature is automatic dependency resolution:

```ruby
class ContactInfo < T::Struct
  const :email, String
  const :phone, T.nilable(String)
end

class Company < T::Struct
  const :name, String
  const :contact, ContactInfo
end

class User < T::Struct
  const :name, String
  const :company, Company
end

# Dependencies included automatically with smart defaults!
User.to_baml
```

**Generated BAML (with correct ordering):**
```baml
class ContactInfo {
  email string
  phone string?
}

class Company {
  name string
  contact ContactInfo
}

class User {
  name string
  company Company
}
```

## Converting Multiple Types

### Manual Collection

```ruby
# Convert multiple types manually
types = [ContactInfo, Company, User]
baml_output = types.map(&:to_baml).join("\n\n")
```

### Legacy API (still supported)

```ruby
# Legacy API for multiple structs
SorbetBaml.from_structs([ContactInfo, Company, User])

# Legacy API for single struct
SorbetBaml.from_struct(User)
```

## Advanced Type Examples

### Complex Enums with Structs

```ruby
class OrderStatus < T::Enum
  enums do
    Pending = new('pending')
    Processing = new('processing')
    Shipped = new('shipped')
    Delivered = new('delivered')
    Cancelled = new('cancelled')
  end
end

class OrderItem < T::Struct
  const :product_id, String
  const :quantity, Integer
  const :price, Float
end

class Order < T::Struct
  const :id, String
  const :status, OrderStatus
  const :items, T::Array[OrderItem]
  const :metadata, T::Hash[String, T.any(String, Integer, Float)]
  const :shipping_address, T.nilable(Address)
end

# Generate complete type definitions
[OrderStatus, OrderItem, Order].map(&:to_baml).join("\n\n")
```

**Generated BAML:**
```baml
enum OrderStatus {
  "pending"
  "processing"
  "shipped"
  "delivered"
  "cancelled"
}

class OrderItem {
  product_id string
  quantity int
  price float
}

class Order {
  id string
  status OrderStatus
  items OrderItem[]
  metadata map<string, string | int | float>
  shipping_address Address?
}
```

### Self-Referential Types

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

## Configuration Options

### Custom Indentation

```ruby
User.to_baml(indent_size: 4)
```

**Generated BAML:**
```baml
class User {
    name string
    age int
}
```

### Field Descriptions

Extract documentation from Ruby comments to provide LLM context:

```ruby
class DocumentedUser < T::Struct
  # User's full legal name for official records
  const :full_name, String
  
  # Age in years, must be 18 or older for account creation
  const :age, Integer
  
  # Primary email address for account notifications
  const :email, String
end

DocumentedUser.to_baml
```

**Generated BAML with descriptions:**
```baml
class DocumentedUser {
  full_name string @description("User's full legal name for official records")
  age int @description("Age in years, must be 18 or older for account creation")
  email string @description("Primary email address for account notifications")
}
```

### Combining Options

```ruby
# Smart defaults: dependencies and descriptions already included!
User.to_baml(indent_size: 4)

# Or disable features if needed
User.to_baml(
  include_dependencies: false,
  include_descriptions: false,
  indent_size: 4
)
```

## File Generation

### Single File Output

```ruby
# Generate and write to file (dependencies included by default)
baml_content = User.to_baml
File.write("types/user.baml", baml_content)
```

### Multiple Files

```ruby
# Generate separate files for each type
[User, Company, ContactInfo].each do |type|
  filename = type.name.downcase.gsub('::', '_')
  File.write("types/#{filename}.baml", type.to_baml)
end
```

### Build Process Integration

```ruby
# Rakefile
desc "Generate BAML type definitions"
task :generate_baml do
  require 'sorbet-baml'
  require_relative 'app/models'
  
  types = [User, Company, Order, Product] # Your app types
  baml_content = types.map(&:to_baml).join("\n\n")
  
  File.write("lib/types.baml", baml_content)
  puts "Generated BAML types in lib/types.baml"
end
```

## LLM Integration Patterns

### With OpenAI Structured Outputs

```ruby
require 'openai'
require 'sorbet-baml'

# Define your response format
class AnalysisResult < T::Struct
  const :sentiment, String
  const :confidence, Float
  const :key_phrases, T::Array[String]
  const :metadata, T::Hash[String, String]
end

# Generate schema for LLM
schema = AnalysisResult.to_baml

client = OpenAI::Client.new
response = client.chat(
  parameters: {
    model: "gpt-4o",
    messages: [
      {
        role: "system",
        content: "Analyze text and respond with data matching this BAML schema:\n\n#{schema}"
      },
      {
        role: "user", 
        content: "Analyze: 'I love this new product!'"
      }
    ]
  }
)
```

### With Anthropic Claude

```ruby
require 'anthropic'
require 'sorbet-baml'

schema = UserProfile.to_baml(include_dependencies: true)

client = Anthropic::Client.new
response = client.messages(
  model: "claude-3-5-sonnet-20241022",
  max_tokens: 1000,
  messages: [
    {
      role: "user",
      content: "Generate a realistic user profile matching this schema:\n\n#{schema}"
    }
  ]
)
```

### With DSPy.rb Integration

```ruby
require 'dspy'
require 'sorbet-baml'

# Your T::Struct automatically works with DSPy signatures
class UserAnalysis < DSPy::Signature
  input { const :user_data, String }
  output { const :analysis, AnalysisResult }  # Uses your T::Struct
end

# The BAML schema is automatically generated for LLM prompts
predictor = DSPy::Predict.new(UserAnalysis)
result = predictor.call(user_data: "John, 25, loves hiking")
```

### Prompt Engineering

```ruby
# Template for complex prompts
def build_analysis_prompt(data, schema)
  <<~PROMPT
    You are a data analyst. Analyze the following data and return results 
    in the exact format specified by this BAML schema:

    #{schema}

    Data to analyze:
    #{data}

    Requirements:
    - Follow the schema exactly
    - Provide confidence scores between 0.0 and 1.0
    - Extract meaningful insights
  PROMPT
end

schema = AnalysisResult.to_baml
prompt = build_analysis_prompt(user_input, schema)
```

## Rails Integration

### Model Integration

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # Your ActiveRecord model...
  
  # Add Sorbet types for API schemas
  class UserAPI < T::Struct
    const :id, Integer
    const :name, String
    const :email, String
    const :created_at, String
  end
  
  def to_api_schema
    UserAPI.to_baml
  end
end

# Usage in controllers
class UsersController < ApplicationController
  def schema
    render json: { schema: User::UserAPI.to_baml }
  end
end
```

### API Documentation

```ruby
# Generate API docs automatically
class ApiDocsGenerator
  API_TYPES = [
    User::UserAPI,
    Order::OrderAPI,
    Product::ProductAPI
  ].freeze
  
  def self.generate
    schema = API_TYPES.map(&:to_baml).join("\n\n")
    File.write("docs/api_schema.baml", schema)
  end
end
```

## Performance Considerations

### Caching Generated BAML

```ruby
class CachedTypeConverter
  def self.to_baml(type)
    @cache ||= {}
    @cache[type] ||= type.to_baml
  end
end

# Use in production for frequently accessed types
schema = CachedTypeConverter.to_baml(User)
```

### Lazy Loading

```ruby
# Only generate BAML when needed (smart defaults apply)
class ApiResponse
  def schema
    @schema ||= self.class.to_baml
  end
end
```
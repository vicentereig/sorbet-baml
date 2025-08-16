# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Running Tests:**
```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path_spec.rb  # Run specific test file
```

**Type Checking:**
```bash
bundle exec srb tc                   # Run Sorbet type checker
```

**Development Setup:**
```bash
bundle install                       # Install dependencies
bundle exec tapioca dsl             # Generate RBI files for gems
bundle exec tapioca gem             # Generate RBI files for dependencies
```

**Linting:**
```bash
bundle exec rubocop                  # Run RuboCop linter
bundle exec rubocop -a              # Auto-fix violations where possible
```

**Gem Tasks:**
```bash
bundle exec rake build              # Build the gem
bundle exec rake install            # Install locally
bundle exec rake release            # Release to RubyGems (maintainers only)
```

## Code Architecture

### Core Components

**Main Library Entry Point:**
- `lib/sorbet_baml.rb` - Main module with public API methods and extension loading

**Core Conversion System:**
- `lib/sorbet_baml/converter.rb` - Main converter orchestrating BAML generation
- `lib/sorbet_baml/type_mapper.rb` - Maps Sorbet type objects to BAML type strings
- `lib/sorbet_baml/dependency_resolver.rb` - Handles topological sorting of dependencies

**Ruby-Idiomatic API Extensions:**
- `lib/sorbet_baml/struct_extensions.rb` - Adds `.to_baml` method to T::Struct
- `lib/sorbet_baml/enum_extensions.rb` - Adds `.to_baml` method to T::Enum

**Field Documentation:**
- `lib/sorbet_baml/comment_extractor.rb` - Extracts comments from source for field descriptions

### Key Design Patterns

**Extension Pattern:** The gem extends T::Struct and T::Enum classes with `.to_baml` methods for a Ruby-idiomatic API.

**Dependency Resolution:** Uses topological sorting to ensure dependencies are output before types that reference them, preventing forward reference issues.

**Type Mapping:** Comprehensive mapping from Sorbet type system to BAML types:
- `T::Struct` → BAML classes
- `T::Enum` → BAML enums  
- `T.nilable(T)` → optional types (`T?`)
- `T::Array[T]` → array types (`T[]`)
- `T::Hash[K,V]` → map types (`map<K,V>`)
- `T.any(T1, T2)` → union types (`T1 | T2`)

**Smart Defaults:** The API includes dependencies and field descriptions by default.

### Type System Support

The gem provides complete coverage of Sorbet's type system:
- Basic types (String, Integer, Float, Boolean, Symbol, Date/Time)
- Complex types (Arrays, Hashes, Unions, Nilable)
- Structured types (T::Struct, T::Enum with full nesting support)
- Circular reference handling to prevent infinite loops

### Testing Structure

- `spec/fixtures/` - Test data including complex type examples
- `spec/integration/` - End-to-end feature tests
- `spec/sorbet_baml/` - Unit tests for each component
- Comprehensive test coverage includes edge cases, circular references, and complex type combinations

## Development Guidelines

**Type Safety:** All code uses `# typed: strict` and maintains full Sorbet compliance.

**Ruby Idioms:** The public API follows Ruby conventions with `.to_baml` instance methods rather than static factory methods.

**Field Descriptions:** Comments above field definitions are automatically extracted and included as BAML `@description` annotations for LLM context.
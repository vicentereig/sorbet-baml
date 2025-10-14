## [Unreleased]

## [0.4.0] - 2025-10-14

### Changed

- **Dramatically reduced gem size from 1.46MB to 20KB (98.6% reduction)**
  - Excluded development-only Sorbet RBI files (`sorbet/` directory - 11MB)
  - Excluded documentation site source (`docs-site/` directory - 43MB)
  - Excluded IDE configuration files (`.idea/` directory)
  - Excluded documentation output (`docs-output/` directory)
  - Excluded RSpec configuration files (`.rspec`)
  - **File count reduced from 134 to 22 essential files**

### Technical Details

The gem now only includes runtime-required files:
- Core library code (`lib/` directory)
- Documentation (README.md, LICENSE.txt, CHANGELOG.md)
- Examples (`examples/` directory)

All Sorbet type checking infrastructure and development tooling remains available in the repository for contributors but is no longer shipped to end users.

### Impact

- **Faster gem installation** - 92% less data to download
- **Smaller disk footprint** - More efficient for deployed applications
- **No functionality changes** - All features work exactly as before
- **Zero breaking changes** - Full backward compatibility maintained

## [0.3.0] - 2025-08-17

### Added

- Comprehensive BAML tool type definitions for agentic workflows
- `.to_baml_tool()` method for T::Struct classes
- Automatic DSPy tool conversion when `dspy.rb` is available
- Tool metadata extraction (`tool_name`, `tool_description`)
- Support for function calling APIs (OpenAI, Anthropic, etc.)

### Improved

- 80+ test cases with comprehensive coverage
- Full Sorbet type safety throughout
- Enhanced documentation with tool examples

## [0.2.0] - 2025-08-16

### Added

- Clean `description:` parameter for `const` and `prop` declarations
- Smart fallback chain: description parameter → Ruby comments → nil
- `DescriptionExtension` for T::Struct
- `DescriptionExtractor` for programmatic access

### Improved

- Better LLM context with rich field descriptions
- Zero breaking changes to existing APIs
- Full backward compatibility

## [0.1.0] - 2025-08-16

- Initial release

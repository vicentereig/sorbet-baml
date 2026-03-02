# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

begin
  require 'dspy'

  module SorbetBaml
    module TestFixtures
      # Simple calculator tool following DSPy pattern
      class CalculatorTool < DSPy::Tools::Base
        extend T::Sig
        
        tool_name 'calculator'
        tool_description 'Performs basic arithmetic operations'

        sig { params(operation: String, num1: Float, num2: Float).returns(T.any(Float, String)) }
        def call(operation:, num1:, num2:)
          case operation.downcase
          when 'add' then num1 + num2
          when 'subtract' then num1 - num2
          when 'multiply' then num1 * num2
          when 'divide'
            return 'Error: Cannot divide by zero' if num2 == 0

            num1 / num2
          else
            "Error: Unknown operation '#{operation}'. Use add, subtract, multiply, or divide"
          end
        end
      end

      # Search tool with optional parameters
      class DSPySearchTool < DSPy::Tools::Base
        extend T::Sig

        tool_name 'search'
        tool_description 'Search for information'

        sig { params(query: String, limit: T.nilable(Integer)).returns(T::Array[String]) }
        def call(query:, limit: nil)
          # Mock implementation
          ["Result 1 for #{query}", "Result 2 for #{query}"].take(limit || 10)
        end
      end

      # Enum for search category filtering
      class SearchCategory < T::Enum
        enums do
          WEB = new('web')
          IMAGES = new('images')
          NEWS = new('news')
          VIDEOS = new('videos')
        end
      end

      # Tool with an array of enums parameter
      class EnumSearchTool < DSPy::Tools::Base
        extend T::Sig

        tool_name 'enum_search'
        tool_description 'Search with category filters'

        sig { params(query: String, categories: T::Array[SearchCategory]).returns(String) }
        def call(query:, categories:)
          "Searching #{query} in #{categories.map(&:serialize).join(', ')}"
        end
      end

      # Tool with a single enum parameter
      class SingleEnumTool < DSPy::Tools::Base
        extend T::Sig

        tool_name 'single_enum'
        tool_description 'Tool with a single enum parameter'

        sig { params(category: SearchCategory).returns(String) }
        def call(category:)
          "Category: #{category.serialize}"
        end
      end
    end
  end
rescue LoadError
  # DSPy not available, skip DSPy tool fixtures
end

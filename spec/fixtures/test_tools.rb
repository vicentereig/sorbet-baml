# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  module TestFixtures
    # Simple tool with just a response field
    class ReplyTool < T::Struct
      const :response, String
    end

    # Tool with action field and description
    class StopTool < T::Struct
      # when it might be a good time to end the conversation
      const :action, String
    end

    # Tool with multiple fields and descriptions
    class SearchTool < T::Struct
      # The search query to execute
      const :query, String
      # Maximum number of results to return
      const :limit, T.nilable(Integer)
    end

    # Tool with complex types
    class UserCreateTool < T::Struct
      # The user's full name
      const :name, String
      # List of user tags
      const :tags, T::Array[String]
      # User preferences as key-value pairs
      const :preferences, T::Hash[String, String]
    end
  end
end

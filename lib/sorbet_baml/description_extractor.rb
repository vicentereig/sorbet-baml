# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  # Extracts description parameters from T::Struct prop and const declarations
  class DescriptionExtractor
    extend T::Sig

    sig { params(klass: T::Class[T.anything]).returns(T::Hash[String, T.nilable(String)]) }
    def self.extract_prop_descriptions(klass)
      descriptions = {}
      
      # Check if this is a T::Struct with props
      return descriptions unless klass.respond_to?(:props)
      
      begin
        T.unsafe(klass).props.each do |field_name, prop_info|
          next unless prop_info.is_a?(Hash)
          
          # Check if the prop has a description in the :extra field
          extra = prop_info[:extra]
          if extra.is_a?(Hash) && extra[:description].is_a?(String)
            descriptions[field_name.to_s] = extra[:description]
          end
        end
      rescue => e
        # Handle any errors gracefully and return empty hash
        return {}
      end
      
      descriptions
    end
  end
end
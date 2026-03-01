# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

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
        # DSPy >= 0.34 stores descriptions via DSPy::Ext::StructDescriptions#field_descriptions
        if klass.respond_to?(:field_descriptions)
          T.unsafe(klass).field_descriptions.each do |field_name, desc|
            descriptions[field_name.to_s] = desc if desc.is_a?(String)
          end
        end

        # Fall back to the legacy :extra hash for structs that store descriptions there
        if descriptions.empty?
          T.unsafe(klass).props.each do |field_name, prop_info|
            next unless prop_info.is_a?(Hash)

            extra = prop_info[:extra]
            descriptions[field_name.to_s] = extra[:description] if extra.is_a?(Hash) && extra[:description].is_a?(String)
          end
        end
      rescue StandardError
        # Handle any errors gracefully and return empty hash
        return {}
      end

      descriptions
    end
  end
end

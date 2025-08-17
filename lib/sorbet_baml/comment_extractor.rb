# typed: strict
# frozen_string_literal: true

module SorbetBaml
  # Extracts documentation comments from Sorbet struct and enum source files
  class CommentExtractor
    extend T::Sig

    sig { params(klass: T.class_of(T::Struct)).returns(T::Hash[String, T.nilable(String)]) }
    def self.extract_field_comments(klass)
      # First try to get descriptions from the description extractor (extra field)
      descriptions = DescriptionExtractor.extract_prop_descriptions(klass)

      # Then fall back to comment-based extraction for any missing descriptions
      comments = {}
      source_file = find_source_file(klass)

      if source_file && File.exist?(source_file)
        lines = File.readlines(source_file)
        extract_comments_from_lines(lines, T.must(T.must(klass.name).split('::').last), comments)
      end

      # Merge with priority: description parameters > comments
      descriptions.merge(comments) { |_key, desc_param, _comment| desc_param }
    end

    sig { params(klass: T.class_of(T::Enum)).returns(T::Hash[String, T.nilable(String)]) }
    def self.extract_enum_comments(klass)
      comments = {}
      source_file = find_source_file(klass)

      return comments unless source_file && File.exist?(source_file)

      lines = File.readlines(source_file)
      extract_enum_comments_from_lines(lines, T.must(T.must(klass.name).split('::').last), comments)

      comments
    end

    sig { params(klass: T::Class[T.anything]).returns(T.nilable(String)) }
    def self.find_source_file(klass)
      # Try to find where the class was defined
      # This is a heuristic approach since Ruby doesn't provide reliable source location for classes

      # Method 1: Check if any methods have source location
      begin
        if klass.respond_to?(:new) && klass.method(:new).respond_to?(:source_location)
          location = klass.method(:new).source_location
          return location[0] if location
        end
      rescue StandardError
        # Ignore errors
      end

      # Method 2: Look at the current call stack for files that might contain the class
      caller_locations.each do |location|
        file_path = location.absolute_path || location.path
        next unless file_path && File.exist?(file_path)

        # Read the file and check if it contains the class definition
        begin
          content = File.read(file_path)
          class_name = T.must(klass.name).split('::').last
          return file_path if content.match(/class\s+#{Regexp.escape(T.must(class_name))}\s*</)
        rescue StandardError
          # Ignore file read errors
        end
      end

      nil
    end

    sig { params(lines: T::Array[String], class_name: String, comments: T::Hash[String, T.nilable(String)]).void }
    def self.extract_comments_from_lines(lines, class_name, comments)
      in_target_class = T.let(false, T::Boolean)
      current_comment = T.let(nil, T.nilable(String))
      brace_depth = 0

      lines.each do |line|
        stripped = line.strip

        # Check if we're entering the target class
        if stripped.match(/^class\s+#{Regexp.escape(class_name)}\s*<\s*T::Struct/)
          in_target_class = true
          brace_depth = 0
          next
        end

        next unless in_target_class

        # Track brace depth to handle nested classes
        brace_depth += stripped.count('{')
        brace_depth -= stripped.count('}')

        # Exit when we reach the end of the class
        break if stripped == 'end' && brace_depth == 0

        # Extract comment
        if stripped.start_with?('#')
          comment_text = T.must(stripped[1..-1]).strip
          current_comment = current_comment ? "#{current_comment} #{comment_text}" : comment_text
        elsif stripped.match(/^const\s+:(\w+)/) && current_comment
          field_name = T.must(stripped.match(/^const\s+:(\w+)/))[1]
          comments[T.must(field_name)] = current_comment
          current_comment = nil
        elsif !stripped.empty? && !stripped.start_with?('#')
          # Reset comment if we hit non-comment, non-const line
          current_comment = nil
        end
      end
    end

    sig { params(lines: T::Array[String], class_name: String, comments: T::Hash[String, T.nilable(String)]).void }
    def self.extract_enum_comments_from_lines(lines, class_name, comments)
      in_target_class = T.let(false, T::Boolean)
      in_enums_block = T.let(false, T::Boolean)
      current_comment = T.let(nil, T.nilable(String))

      lines.each do |line|
        stripped = line.strip

        # Check if we're entering the target enum class
        if stripped.match(/^class\s+#{Regexp.escape(class_name)}\s*<\s*T::Enum/)
          in_target_class = true
          next
        end

        next unless in_target_class

        # Check if we're in the enums block
        if stripped == 'enums do'
          in_enums_block = true
          next
        end

        # Exit enums block
        if in_enums_block && stripped == 'end'
          in_enums_block = false
          next
        end

        # Exit class
        break if stripped == 'end' && !in_enums_block

        next unless in_enums_block

        # Extract comment
        if stripped.start_with?('#')
          comment_text = T.must(stripped[1..-1]).strip
          current_comment = current_comment ? "#{current_comment} #{comment_text}" : comment_text
        elsif stripped.match(/^(\w+)\s*=\s*new/) && current_comment
          enum_name = T.must(stripped.match(/^(\w+)\s*=\s*new/))[1]
          comments[T.must(enum_name)] = current_comment
          current_comment = nil
        elsif !stripped.empty? && !stripped.start_with?('#')
          # Reset comment if we hit non-comment, non-enum line
          current_comment = nil
        end
      end
    end
  end
end

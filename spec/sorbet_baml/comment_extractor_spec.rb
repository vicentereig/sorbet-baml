# typed: false
# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe SorbetBaml::CommentExtractor do
  describe ".extract_field_comments" do
    it "extracts comments from struct fields" do
      # Create a test file with documented struct
      test_file = Tempfile.new(['test_struct', '.rb'])
      test_file.write(<<~RUBY)
        class DocumentedUser < T::Struct
          # User's full name for display
          const :name, String
          
          # Age in years, must be positive
          const :age, Integer
          
          # Optional email for notifications
          const :email, T.nilable(String)
        end
      RUBY
      test_file.close
      
      # Mock the source file finding
      allow(described_class).to receive(:find_source_file).and_return(test_file.path)
      
      # Create a mock class
      mock_class = Class.new(T::Struct) do
        const :name, String
        const :age, Integer
        const :email, T.nilable(String)
      end
      stub_const("DocumentedUser", mock_class)
      
      comments = described_class.extract_field_comments(DocumentedUser)
      
      expect(comments).to eq({
        "name" => "User's full name for display",
        "age" => "Age in years, must be positive", 
        "email" => "Optional email for notifications"
      })
      
      test_file.unlink
    end
    
    it "handles multiline comments" do
      test_file = Tempfile.new(['test_struct', '.rb'])
      test_file.write(<<~RUBY)
        class MultilineUser < T::Struct
          # This is a very long comment
          # that spans multiple lines
          # and describes the field in detail
          const :description, String
        end
      RUBY
      test_file.close
      
      allow(described_class).to receive(:find_source_file).and_return(test_file.path)
      
      mock_class = Class.new(T::Struct) do
        const :description, String
      end
      stub_const("MultilineUser", mock_class)
      
      comments = described_class.extract_field_comments(MultilineUser)
      
      expect(comments["description"]).to eq("This is a very long comment that spans multiple lines and describes the field in detail")
      
      test_file.unlink
    end
    
    it "returns empty hash when no source file found" do
      allow(described_class).to receive(:find_source_file).and_return(nil)
      
      mock_class = Class.new(T::Struct) do
        const :name, String
      end
      
      comments = described_class.extract_field_comments(mock_class)
      expect(comments).to eq({})
    end
  end
  
  describe ".extract_enum_comments" do
    it "extracts comments from enum values" do
      # Test the comment extraction directly from lines
      lines = [
        "class DocumentedStatus < T::Enum",
        "  enums do",
        "    # User account is active and verified",
        "    Active = new('active')",
        "    ",
        "    # User account is temporarily suspended",
        "    Suspended = new('suspended')",
        "    ",
        "    # User account has been permanently deleted",
        "    Deleted = new('deleted')",
        "  end",
        "end"
      ]
      
      comments = {}
      described_class.send(:extract_enum_comments_from_lines, lines, "DocumentedStatus", comments)
      
      expect(comments).to eq({
        "Active" => "User account is active and verified",
        "Suspended" => "User account is temporarily suspended",
        "Deleted" => "User account has been permanently deleted"
      })
    end
  end
end
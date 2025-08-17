# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

module SorbetBaml
  module TestFixtures
    class Status < T::Enum
      enums do
        Pending = new('pending')
        Active = new('active')
        Inactive = new('inactive')
      end
    end

    class Priority < T::Enum
      enums do
        Low = new('low')
        Medium = new('medium')
        High = new('high')
        Critical = new('critical')
      end
    end

    class UserRole < T::Enum
      enums do
        Admin = new('admin')
        User = new('user')
        Guest = new('guest')
      end
    end
  end
end

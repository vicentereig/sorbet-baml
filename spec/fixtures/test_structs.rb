# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  module TestFixtures
    class SimpleUser < T::Struct
      const :name, String
      const :age, Integer
    end

    class UserWithOptionals < T::Struct
      const :name, String
      const :email, T.nilable(String)
      const :age, T.nilable(Integer)
    end

    class UserWithArrays < T::Struct
      const :tags, T::Array[String]
      const :scores, T::Array[Integer]
    end

    class Address < T::Struct
      const :street, String
      const :city, String
    end

    class UserWithAddress < T::Struct
      const :name, String
      const :address, Address
    end

    class User < T::Struct
      const :name, String
      const :address, Address
    end
  end
end
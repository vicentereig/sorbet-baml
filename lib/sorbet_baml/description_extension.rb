# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module SorbetBaml
  # Extension module to add description: parameter support to T::Struct
  module DescriptionExtension
    extend T::Sig
    
    # Override const to support description parameter
    sig { params(name: Symbol, type: T.untyped, description: T.nilable(String), kwargs: T.untyped).void }
    def const(name, type, description: nil, **kwargs)
      if description
        super(name, type, extra: { description: description }, **kwargs)
      else
        super(name, type, **kwargs)
      end
    end
    
    # Override prop to support description parameter  
    sig { params(name: Symbol, type: T.untyped, description: T.nilable(String), kwargs: T.untyped).void }
    def prop(name, type, description: nil, **kwargs)
      if description
        super(name, type, extra: { description: description }, **kwargs)
      else
        super(name, type, **kwargs)
      end
    end
  end
end

# Automatically extend T::Struct with description support
T::Struct.extend(SorbetBaml::DescriptionExtension)
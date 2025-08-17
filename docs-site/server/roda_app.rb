class RodaApp < Bridgetown::Rack::Roda
  route do |r|
    # Handle static assets first
    r.public

    # Handle Bridgetown routes
    r.bridgetown
  end
end

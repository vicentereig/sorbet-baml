if ENV["BRIDGETOWN_ENV"] == "production"
  bind "tcp://0.0.0.0:#{ENV.fetch("PORT", 4000)}"
else
  bind "tcp://127.0.0.1:#{ENV.fetch("PORT", 4000)}"
end

environment ENV.fetch("BRIDGETOWN_ENV", "development")

plugin :tmp_restart
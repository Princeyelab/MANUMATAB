RubyLLM.configure do |config|
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY")
  config.default_model = "gpt-4o-mini"
end
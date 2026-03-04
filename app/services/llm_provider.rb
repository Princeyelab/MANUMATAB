class LlmProvider
  MODEL = "claude-opus-4-6"
  MAX_TOKENS = 1024

  def initialize(system_prompt:, messages:)
    @system_prompt = system_prompt
    @messages = messages
    @client = Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))
  end

  def call
    response = @client.messages.create(
      model: MODEL,
      max_tokens: MAX_TOKENS,
      system: @system_prompt,
      messages: @messages
    )
    response.content.first.text
  end
end

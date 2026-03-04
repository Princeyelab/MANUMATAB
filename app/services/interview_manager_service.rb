class InterviewManagerService
  def initialize(chat)
    @chat = chat
    @interview = chat.interview
  end

  def start_interview
    system_prompt = build_system_prompt

    response = LlmProvider.new(
      system_prompt: system_prompt,
      messages: [{ role: "user", content: "Commençons l'entretien." }]
    ).call

    @chat.messages.create!(role: "assistant", content: response)
  end

  def reply_to(user_content)
    @chat.messages.create!(role: "user", content: user_content)

    history = @chat.messages.order(:created_at).map do |m|
      { role: m.role, content: m.content }
    end

    response = LlmProvider.new(
      system_prompt: build_system_prompt,
      messages: history
    ).call

    @chat.messages.create!(role: "assistant", content: response)
  end

  private

  def build_system_prompt
    <<~PROMPT
      Tu es un recruteur expert qui conduit des entretiens d'embauche professionnels en français.

      Poste visé : #{@interview.job_title}
      #{"Lien vers l'offre : #{@interview.job_url}" if @interview.job_url.present?}

      Ton rôle :
      - Mener un entretien structuré et réaliste
      - Poser UNE question à la fois, attendre la réponse avant de continuer
      - Evaluer les réponses du candidat avec bienveillance mais exigence
      - Alterner questions comportementales (STAR), techniques, et motivation

      Commence par te présenter brièvement en tant que recruteur, puis pose ta première question.
    PROMPT
  end
end

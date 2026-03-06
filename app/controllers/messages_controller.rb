class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = "Tu es Dalloway, un coach d’entretien d’embauche utile, clair, bienveillant et structuré. Tu aides l'utilisateur à se préparer à un entretien d'embauche. Tu poses des questions pertinentes, tu aides à reformuler ses réponses, et tu donnes des conseils concrets."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    interview = @chat.interview

    @message = @chat.messages.new(
      content: message_params[:content],
      role: "user"
    )

    if @message.save
      context = build_context(interview)

      chat = RubyLLM.chat do |c|
        c.system "#{SYSTEM_PROMPT}\n\n#{context}"

        @chat.messages.where.not(id: @message.id).order(:created_at).each do |m|
          if m.role == "assistant"
            c.assistant m.content
          else
            c.user m.content
          end
        end
      end

      answer = chat.ask(@message.content)

  def process_file(file)
    if file.content_type == "application/pdf"
      send_question(model: "gpt-4.1-2025-04-14", with: { pdf: @message.file.url })
    elsif file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url })
    end
  end

      @assistant_message = @chat.messages.create!(
        role: "assistant",
        content: answer.content
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      @messages = @chat.messages.order(created_at: :asc)
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_context(interview)
    <<~TEXT
      Contexte entretien :
      - Poste visé : #{interview.job_title.presence || 'non précisé'}
      - Lien de l’offre : #{interview.job_url.presence || 'non fourni'}
      - CV uploadé : #{interview.file.attached? ? "oui (nom du fichier : #{interview.file.filename})" : 'non'}

      Consigne :
      - Tu dois te comporter comme un coach d’entretien.
      - Tu dois aider l’utilisateur à se préparer au poste visé.
      - Tu peux poser des questions d’entretien, demander des précisions, reformuler ses réponses et donner du feedback.
      - Si certaines informations manquent, tu dois quand même poursuivre l’entraînement intelligemment.
    TEXT
  end

  def message_params
    params.require(:message).permit(:content)
  end
end

class InterviewsController < ApplicationController
  before_action :authenticate_user!

  def index
    @interviews = current_user.interviews
  end

  def show
    @interview = Interview.find(params[:id])
    @chat = @interview.chats.first
    @messages = @chat.messages.order(:created_at)
    @new_message = Message.new
  end

  def create
    @interview = current_user.interviews.build(interview_params)
    @interview.status = "active"

    if @interview.save
      @chat = Chat.create!(
        interview: @interview,
        user: current_user
      )

      seed_initial_assistant_message

      redirect_to chat_path(@chat)
    else
      render "pages/home", status: :unprocessable_entity
    end
  end

  private

  def seed_initial_assistant_message
    cv_status = @interview.file.attached? ? "J’ai bien reçu ton CV." : "Je n’ai pas encore reçu ton CV."
    offer_status = @interview.job_url.present? ? "J’ai aussi pris en compte l’offre que tu vises." : "Je n’ai pas encore reçu de lien d’offre."

    intro = <<~TEXT
      Bonjour, je suis Dalloway, ton coach d’entretien IA.

      #{cv_status}
      #{offer_status}

      Nous allons préparer ton entretien pour le poste de #{@interview.job_title.presence || 'ciblé'}.

      Je vais t’aider à t’entraîner avec des questions pertinentes, puis je te donnerai du feedback sur tes réponses.

      Pour commencer : peux-tu me présenter ton parcours en 2 minutes, comme si tu étais face à un recruteur ?
    TEXT

    @chat.messages.create!(
      role: "assistant",
      content: intro
    )
  end

  def interview_params
    params.require(:interview).permit(:job_title, :job_url, :file)
  end
end

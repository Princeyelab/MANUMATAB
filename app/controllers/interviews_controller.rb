class InterviewsController < ApplicationController
  SYSTEM_PROMPT = `Tu est mon assistant de test pour embauche. Tu dois   analyser  CV et lien d offre d 'emploie, me poser des questions afin de voir si mon profil correspond a cete offre`

  def index
    @interviews = Interview.all
  end

  def show
    @interview = Interview.find(params[:id])
  end

  def create
    @interview = current_user.interviews.build(interview_params)
    @interview.status = "pending" # On commence en attente

    if @interview.save!
      @chat = Chat.create(
        interview_id: @interview.id,
        user_id: current_user.id
      )
      process_file(@interview.file)
      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages.order(created_at: :asc)
      render "chats/show", status: :unprocessable_entity
    end
  end

  def show
    @interview = Interview.find(params[:id])
    @chat = @interview.chats.first # On récupère le chat créé plus haut
    @messages = @chat.messages.order(:created_at)
    @new_message = Message.new # Pour le formulaire d'envoi de message
  end

  private

  def process_file(file)
    @ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1-2025-04-14")
    @ruby_llm_chat.with_instructions(SYSTEM_PROMPT)
    @response = @ruby_llm_chat.ask("lis le pdf et l'offre d'emploi dans cette url : #{params[:interview][:job_url]} et commence la discussion",
                                   with: file.url)
    Message.create(role: "assistant", content: @response.content, chat_id: @chat.id)
  end

  def interview_params
    # On autorise les champs du formulaire + le CV si tu l'as ajouté
    params.require(:interview).permit(:job_title, :job_description, :file)
  end
end

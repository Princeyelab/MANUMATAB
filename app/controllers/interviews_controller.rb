class InterviewsController < ApplicationController
  before_action :authenticate_user!

  def index
    @interviews = Interview.all
  end

  def show
    @interview = Interview.find(params[:id])
  end

  def create
    # 1. On prépare l'entretien lié à l'utilisateur connecté
    @interview = current_user.interviews.build(interview_params)
    @interview.status = "pending" # On commence en attente
    

    if @interview.save
      @chat = @interview.chats.create!(user: current_user)
      @interview.update!(status: "active")

      InterviewManagerService.new(@chat).start_interview

      redirect_to interview_path(@interview), notice: "L'entretien a démarré !"
    else
      # Si erreur (ex: job_title vide), on réaffiche la home avec les erreurs
      render "pages/home", status: :unprocessable_entity
    end
  end

  def show
    @interview = Interview.find(params[:id])
    @chat = @interview.chats.first # On récupère le chat créé plus haut
    @messages = @chat.messages.order(:created_at)
    @new_message = Message.new # Pour le formulaire d'envoi de message
  end

  private

  def interview_params
    # On autorise les champs du formulaire + le CV si tu l'as ajouté
    params.require(:interview).permit(:job_title, :job_description, :cv)
  end
end

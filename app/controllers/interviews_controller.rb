class InterviewsController < ApplicationController
  before_action :authenticate_user!

  def create
    # 1. On prépare l'entretien lié à l'utilisateur connecté
    @interview = current_user.interviews.build(interview_params)
    @interview.status = "pending" # On commence en attente
    

    if @interview.save
      # 2. Création automatique du Chat associé
      # Puisque Interview has_many :chats, on crée le premier ici
      @interview.chats.create!

      # 3. Redirection vers la "Page 2" (le chat)
      redirect_to interview_path(@interview), notice: "Préparation de votre coach en cours..."
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

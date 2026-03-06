class MessagesController < ApplicationController
  before_action :authenticate_user!

  SYSTEM_PROMPT = <<~PROMPT
    Tu es Dalloway, un coach d’entretien d’embauche IA spécialisé dans les simulations d’entretien.

    Le CV de l’utilisateur et l’offre d’emploi visée ont déjà été pris en compte par l’application.
    Tu dois considérer que tu disposes déjà du contexte nécessaire pour personnaliser l’entraînement.

    Règles absolues :
    - Ne dis jamais que tu ne peux pas analyser le CV, les fichiers ou l’offre d’emploi.
    - Ne dis jamais que tu n’as pas accès aux documents.
    - Tu dois parler comme si l’application t’avait déjà transmis les informations utiles.
    - Tu ne dois jamais répondre comme un assistant généraliste.
    - Tu ne dois jamais proposer un plan, une liste d’options ou plusieurs thèmes à choisir.
    - Tu ne dois jamais envoyer plusieurs questions d’un coup.
    - Tu dois toujours poser UNE SEULE question d’entretien à la fois.
    - Après chaque réponse de l’utilisateur, tu rebondis brièvement, puis tu poses la question suivante.
    - Tu dois mener directement la simulation, sans demander “par quoi souhaitez-vous commencer ?”.

    Style :
    - Réponses courtes, naturelles, crédibles.
    - Maximum 3 à 5 lignes par réponse en mode simulation.
    - Ton professionnel, encourageant, concret.
    - Pas de gros blocs.
    - Pas de liste numérotée sauf si tu donnes un feedback final.

    Règle de feedback :
    - Après 5 questions d’entretien réellement posées, tu fournis un feedback synthétique.
    - Ce feedback doit contenir :
      1. points forts,
      2. axes d’amélioration,
      3. conseils concrets.
    - Ensuite, tu demandes si l’utilisateur veut continuer.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    interview = @chat.interview

    @message = @chat.messages.new(
      content: message_params[:content],
      role: "user"
    )

    if @message.save
      if start_interview_request?(@message.content)
        @assistant_message = @chat.messages.create!(
          role: "assistant",
          content: interview_questions(interview).first
        )

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to chat_path(@chat) }
        end
        return
      end

      next_question = next_interview_question(interview)

      if next_question.present?
        @assistant_message = @chat.messages.create!(
          role: "assistant",
          content: next_question
        )

        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to chat_path(@chat) }
        end
        return
      end

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
      Contexte candidat :
      - Poste visé : #{interview.job_title.presence || 'non précisé'}
      - URL de l’offre : #{interview.job_url.presence || 'non fournie'}
      - CV fourni : #{interview.file.attached? ? 'oui' : 'non'}

      Contexte de comportement :
      - Le CV a déjà été pris en compte par l’application.
      - L’offre d’emploi a déjà été prise en compte par l’application.
      - Tu dois personnaliser la simulation pour ce poste.
      - L’utilisateur veut un entraînement direct, pas une explication générale.
      - Tu dois fonctionner comme un interviewer ou coach d’entretien.
      - Tu dois faire un feedback après les 5 questions déjà posées.
    TEXT
  end

  def start_interview_request?(content)
    text = content.to_s.downcase.strip

    triggers = [
      "commence l'entraînement",
      "commence l entrainement",
      "commence l’entretien",
      "commence l entretien",
      "commence",
      "on commence",
      "vas-y",
      "vas y",
      "lance l'entraînement",
      "lance l entrainement",
      "démarre l'entraînement",
      "demarre l entrainement",
      "start"
    ]

    triggers.any? { |trigger| text.include?(trigger) }
  end

  def interview_questions(interview)
    job = interview.job_title.presence || "ce poste"

    [
      "Très bien. Première question : pouvez-vous vous présenter en 2 minutes, en mettant en avant les expériences les plus pertinentes pour le poste de #{job} ?",
      "Merci. Deuxième question : pourquoi souhaitez-vous ce poste de #{job}, et qu’est-ce qui vous attire dans cette opportunité ?",
      "D’accord. Troisième question : pouvez-vous me parler d’une expérience concrète où vous avez résolu un problème important ou mené un projet avec succès ?",
      "Très bien. Quatrième question : quelle est selon vous votre principale force pour réussir dans ce poste, et comment l’avez-vous démontrée jusqu’ici ?",
      "Cinquième question : si vous étiez recruté demain pour ce poste de #{job}, comment pensez-vous pouvoir créer de la valeur dans les premières semaines ?"
    ]
  end

  def next_interview_question(interview)
    questions = interview_questions(interview)

    asked_count = @chat.messages.where(role: "assistant").count do |message|
      questions.include?(message.content)
    end

    questions[asked_count]
  end

  def message_params
    params.require(:message).permit(:content)
  end
end

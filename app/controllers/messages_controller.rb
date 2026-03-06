class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = `Tu est mon assistant de test pour embauche. Tu dois   analyser  CV et lien d offre d 'emploie, me poser des questions afin de vpor si mon profil correspond a cete offre` # rubocop:disable Layout/LineLength

  def create
    @chat = current_user.chats.find(params[:chat_id])


    # ✅ front safe : le user ne choisit pas son role
    @message = @chat.messages.new(content: message_params[:content], role: "user")

    if @message.save
      if @message.file.attached?
        process_file(@message.file) # send question w/ file to the appropriate model
      else
        send_question # send question to the model
      end

      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages.order(created_at: :asc)
      render "chats/show", status: :unprocessable_entity
    end
  end

  private



  def process_file(file)
    if file.content_type == "application/pdf"
      send_question(model: "gemini-2.0-flash", with: { pdf: @message.file.url })
    elsif file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url })
    end
  end


  def message_params
    params.require(:message).permit(:content)
    params.require(:message).permit(:content, :role, :file)
  end
end

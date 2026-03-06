class MessagesController < ApplicationController
  before_action :authenticate_user!
  SYSTEM_PROMPT = `Tu est mon assistant de test pour embauche. Tu dois   analyser  CV et lien d offre d 'emploie, me poser des questions afin de vpor si mon profil correspond a cete offre` # rubocop:disable Layout/LineLength

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat

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
    params.require(:message).permit(:content, :role, :file)
  end
end

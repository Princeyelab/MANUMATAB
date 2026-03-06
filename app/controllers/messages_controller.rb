class MessagesController < ApplicationController
  before_action :authenticate_user!


  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat

  end

  private


  def process_file(file)
    if file.content_type == "application/pdf"
      send_question(model: "gpt-4.1-2025-04-14", with: { pdf: @message.file.url })
    elsif file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url })
    end
  end

  def message_params
    params.require(:message).permit(:content, :role, :file)
  end
end

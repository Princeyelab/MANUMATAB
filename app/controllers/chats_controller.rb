class ChatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages.order(created_at: :asc)
    @message = Message.new
  end
end

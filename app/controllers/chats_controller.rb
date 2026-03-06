class ChatsController < ApplicationController
  before_action :authenticate_user!
def index
  @interviews = Interview.all
end
  def show
    @chat = Chat.find(params[:id])
    @messages = @chat.messages.order(:created_at)
    @message = Message.new
  end
end

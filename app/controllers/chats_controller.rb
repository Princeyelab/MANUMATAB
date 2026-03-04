class ChatsController < ApplicationController
  before_action :authenticate_user!

  def show
    @interview = Interview.find(params[:interview_id])
    @chat = @interview.chats.find(params[:id])
    @messages = @chat.messages.where(role: %w[user assistant]).order(:created_at)
  end
end

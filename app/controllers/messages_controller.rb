class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    content = params[:message][:content].to_s.strip

    if content.present?
      InterviewManagerService.new(@chat).reply_to(content)
    end

    redirect_to interview_path(@chat.interview)
  end
end

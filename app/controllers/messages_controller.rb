class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = Chat.find(params[:chat_id])
    content = params[:message][:content].to_s.strip

    if content.present?
      InterviewManagerService.new(@chat).reply_to(content)
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    if @message.save
      chat = RubyLLM.chat do |c|
        c.system "Tu es un assistant utile."

        # Contexte = tous les anciens messages du chat (sans celui qu'on vient de créer)
        @chat.messages.where.not(id: @message.id).order(:created_at).each do |m|
          if m.role == "assistant"
            c.assistant m.content
          else
            c.user m.content
          end
        end
      end

      answer = chat.ask(@message.content)

      Message.create!(
        chat: @chat,
        role: "assistant",
        content: answer.content
      )
      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages.order(created_at: :asc)
      render "chats/show", status: :unprocessable_entity
    end

    redirect_to interview_path(@chat.interview)
  end
end

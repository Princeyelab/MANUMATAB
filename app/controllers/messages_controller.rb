class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = current_user.chats.find(params[:chat_id])

    # ✅ front safe : le user ne choisit pas son role
    @message = @chat.messages.new(content: message_params[:content], role: "user")

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

      # ✅ important pour turbo_stream : on garde une instance variable
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

  def message_params
    params.require(:message).permit(:content)
  end
end

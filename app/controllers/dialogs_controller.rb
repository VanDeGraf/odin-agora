class DialogsController < ApplicationController
  def show
    @interlocutor = User.find(params[:id])
    @messages = current_user.dialog_messages(@interlocutor.id)
    @message = Message.new
  end

  def index
    @interlocutors = current_user.interlocutors
  end

  def create_message
    @message = current_user.sent_messages.create(recipient_id: params[:id].to_i,
                                                 body: params[:message][:body])
    redirect_back fallback_location: dialogs_path
  end
end

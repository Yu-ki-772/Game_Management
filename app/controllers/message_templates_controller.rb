class MessageTemplatesController < ApplicationController
  # ログイン前でも許可
  skip_before_action :authenticate_user!
  def index
    @message_templates = MessageTemplate.all
  end
end

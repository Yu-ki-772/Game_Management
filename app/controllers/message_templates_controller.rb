class MessageTemplatesController < ApplicationController
  def index
    @message_templates = MessageTemplate.all
  end
end

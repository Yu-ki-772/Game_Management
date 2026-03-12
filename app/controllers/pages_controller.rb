# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:privacy_policy, :terms]

  def privacy_policy
  end

  def terms
  end
end
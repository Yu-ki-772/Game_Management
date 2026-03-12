# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :privacy_policy, :terms ]

  # プライバシーポリシー
  def privacy_policy
  end

  # 利用規約
  def terms
  end

  def others
  end
end

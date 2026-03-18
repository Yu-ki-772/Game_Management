# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :privacy_policy, :terms ]

  # 「その他」画面
  def others
  end

  # プライバシーポリシー
  def privacy_policy
  end

  # 利用規約
  def terms
  end

  # 使い方ガイド
  def guide
  end
end

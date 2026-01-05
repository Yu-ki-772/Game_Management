class HomeController < ApplicationController
  # ログイン前でも許可
  skip_before_action :authenticate_user!
  def top
  end
end

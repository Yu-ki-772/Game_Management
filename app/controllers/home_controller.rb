class HomeController < ApplicationController
  include CalendarLoadable

  skip_before_action :authenticate_user!

  def top
    if user_signed_in?
      load_calendar_data
    end
  end
end

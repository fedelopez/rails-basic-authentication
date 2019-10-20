class PagesController < ApplicationController
  def home
    @logged_in_user = User.find_by :id => session[:user_id]
  end
end

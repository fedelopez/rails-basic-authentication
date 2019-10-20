class AboutController < ApplicationController
  before_action :authorize_user
  def me
    @logged_in_user = User.find_by :id => session[:user_id]
  end
end

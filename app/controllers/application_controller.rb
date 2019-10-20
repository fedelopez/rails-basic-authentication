class ApplicationController < ActionController::Base
  before_action :fetch_user

  private
  def fetch_user
    if session[:user_id].present?
      @current_user = User.find_by :id => session[:user_id]
      session[:user_id] = nil unless @current_user
    end
  end

  def authorize_user
    redirect_to '/login' unless @current_user.present?
  end
end

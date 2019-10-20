class SessionController < ApplicationController
  def new
    @error_message = flash[:error]
  end

  def create
    user = User.find_by :email => params[:email]
    if user.present? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash[:error] = 'Invalid credentials'
      redirect_to '/login'
    end
  end

  def destroy
  end
end

class PpyLoginController < ApplicationController
  def show
    redirect_to home_path if current_user
  end

  def logout
    sign_out :user
    redirect_to Warden::PpyAuthStrategy.py_logout_url, allow_other_host: true 
  end
end
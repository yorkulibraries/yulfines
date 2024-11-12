class RootController < ApplicationController
  def show
    redirect_to home_path if current_user
  end
end
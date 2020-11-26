class FromPrimoController < ApplicationController
  before_action :redirect_to_home_if_singed_in

  def show
  end

  def redirect_to_home_if_singed_in
    redirect_to home_path if current_user
  end

end

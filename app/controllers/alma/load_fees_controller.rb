class Alma::LoadFeesController < AuthenticatedController

  def index
    Alma::FeeLoader.load_and_update_fees current_user
    TLOG.log_load_fees username: current_user.username

    session[:alma_fees_loaded] = true
    redirect_to root_path
  end

  def reload
    Alma::FeeLoader.load_and_update_fees current_user
    TLOG.log_load_fees username: current_user.username
  end
end

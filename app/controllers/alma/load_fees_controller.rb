class Alma::LoadFeesController < AuthenticatedController

  def index
    Alma::FeeLoader.load_and_update_fees current_user
    TLOG.log_load_fees yorku_id: current_user.yorku_id

    session[:alma_fees_loaded] = true
    redirect_to root_path
  end

  def reload
    Alma::FeeLoader.load_and_update_fees current_user
    TLOG.log_load_fees yorku_id: current_user.yorku_id
  end
end

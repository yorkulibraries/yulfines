class Alma::LoadFeesController < AuthenticatedController

  def index
    yorku_id = current_user.yorku_id #params[:uid]

    if yorku_id
      Alma::FeeLoader.load_and_update_fees yorku_id
    end
    TLOG.log_load_fees yorku_id: current_user.yorku_id

    session[:alma_fees_loaded] = true
    redirect_to root_path
  end
end

class AdminController < AuthenticatedController
  before_action :redirect_if_not_admin

  private
  def redirect_if_not_admin
    if ! current_user.admin?
      redirect_to root_path, notice: "Admin Only Functions"
    end
  end
end

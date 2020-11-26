class PpyLoginController < AuthenticatedController
  def show    
    redirect_to root_path
  end
end

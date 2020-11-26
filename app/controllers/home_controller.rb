class HomeController < AuthenticatedController
  before_action :load_alma_fees

  def show
    @fees = Alma::Fee.active.where(yorku_id: current_user.yorku_id)
    @active_fees = @fees.reject { |f| f.payment_pending? }
    @osgoode_fees = @active_fees.reject { |f| f.owner_id != Alma::Fee::OWNER_OSGOODE}
    @other_fees = @active_fees.reject { |f| f.owner_id == Alma::Fee::OWNER_OSGOODE}

    @processing_fees = @fees.reject { |f| ! f.payment_pending? }
  end

  private
  def load_alma_fees
    if session[:alma_fees_loaded] == nil
      redirect_to load_alma_fees_path
    end
  end
end

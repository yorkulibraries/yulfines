class HomeController < AuthenticatedController
  def show
  end

  def load_fees
    Alma::FeeLoader.load_and_update_fees current_user
    TLOG.log_load_fees username: current_user.username

    @fees = Alma::Fee.active.where(user_primary_id: current_user.username)
    @active_fees = @fees.reject { |f| f.payment_pending? }
    @osgoode_fees = @active_fees.reject { |f| f.owner_id != Alma::Fee::OWNER_OSGOODE}
    @other_fees = @active_fees.reject { |f| f.owner_id == Alma::Fee::OWNER_OSGOODE}
    @processing_fees = @fees.reject { |f| ! f.payment_pending? }
  end
end

class Alma::Fee < ApplicationRecord
  ## TABLE PREFIX - DON'T CHANGE OR IT WILL MESS WITH THE DATABASE ##
  self.table_name_prefix = "alma_"

  ## CONSTANTS ##
  STATUS_PAID = "CLOSED"
  STATUS_STALE = "YUL_MARKED_STALE"
  OWNER_OSGOODE = "YORK-LAW"

  ## SCOPES ##
  scope :active, -> { where.not(fee_status: STATUS_PAID).where.not(fee_status: STATUS_STALE) }
  scope :paid, -> { where(fee_status: STATUS_PAID) }
  scope :stale, -> { where(fee_status: STATUS_STALE) }

  scope :osgoode_fees, -> { where(owner_id: OWNER_OSGOODE) }
  scope :other_fees, -> { where.not(owner_id: OWNER_OSGOODE) }

  ## HELPER METHODS ##
  def payment_pending?
    # if there is a payment record in the processing state
    record = PaymentRecord.where(alma_fee_id: fee_id, status: PaymentRecord::STATUS_PROCESSING).first

    if record && !paid?
      true
    else
      false
    end
  end

  def paid?
    fee_status == STATUS_PAID
  end

  def stale?
    fee_status == STATUS_STALE
  end

  def mark_as_stale!
    update fee_status: STATUS_STALE
  end

end

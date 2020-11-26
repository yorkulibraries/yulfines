class PaymentRecord < ApplicationRecord

  ## CONSTANTS
  STATUS_PROCESSING = "processing"
  STATUS_ABANDONDED = "abandoned"
  STATUS_PAID = "paid"
  STATUS_REJECTED = "rejected"
  STATUS_YPB_INCOMPLETE = "ypb_incomplete"

  ## RELATIONSHIPS ##
  belongs_to :fee, class_name: "Alma::Fee"
  belongs_to :user
  belongs_to :payment_transaction, foreign_key: "transaction_id", class_name: "PaymentTransaction"

  ## VALIDATIONS ##
  validates_presence_of :amount
  validate :fee_belongs_to_user?

  ## SCOPES ##
  scope :processing, -> { where status: STATUS_PROCESSING }
  scope :paid, -> { where(status: STATUS_PAID) }
  scope :rejected, -> { where(status: STATUS_REJECTED) }

  ## CALLBACKS
  after_create :set_status_to_processing
  after_create :update_yorku_id_and_alma_fee_id
  after_create :copy_additional_alma_fee_details


  def mark_paid!
    if status == STATUS_PROCESSING
      update status: STATUS_PAID, alma_fines_paid_at: Date.current
      fee.update_attribute :fee_status, Alma::Fee::STATUS_PAID
    end
  end

  def mark_incomplete!
    if status == STATUS_PROCESSING
      update_attribute :status, STATUS_YPB_INCOMPLETE
    end
  end

  def paid?
    status == STATUS_PAID
  end

  def mark_rejected!(error_code: nil, error_message: nil, tracking_id: nil)
    if status == STATUS_PROCESSING
      update_attribute :status, STATUS_REJECTED
      update_attribute :alma_fines_rejected_at, Date.current
      update_attribute :alma_fines_rejected_error_reason, error_message
      update_attribute :alma_fines_rejected_error_code, error_code
      update_attribute :alma_fines_rejected_error_tracking_id, tracking_id
    end
  end

  def mark_abandonned!
    if status == STATUS_PROCESSING
      update_attribute :status, STATUS_ABANDONDED
    end
  end

  def rejected?
    status == STATUS_REJECTED
  end

  def processing?
    status == STATUS_PROCESSING
  end

  private
  def fee_belongs_to_user?
    if fee.try(:yorku_id) != user.try(:yorku_id)
      errors.add(:fee, "Fee must belong to the user")
    end
  end

  def set_status_to_processing
    update_attribute :status, STATUS_PROCESSING
  end

  def update_yorku_id_and_alma_fee_id
    update_attribute :yorku_id, user.yorku_id #if self[:yorku_id] == nil
    update_attribute :alma_fee_id, fee.fee_id
  end

  def copy_additional_alma_fee_details
    update_attribute :fee_owner_id, fee.owner_id
    update_attribute :fee_owner_description, fee.owner_description
    update_attribute :fee_item_title, fee.item_title
    update_attribute :fee_item_barcode, fee.item_barcode
  end
end

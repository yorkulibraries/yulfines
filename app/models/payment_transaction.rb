class PaymentTransaction < ApplicationRecord

  ## CONSTANTS ##
  PAYMENT_TYPE = Settings.ypb.transaction_types.purchase

  ## YPB RESPONSE CODES ##
  STATUS_APPROVED = Settings.ypb.transaction_statuses.approved
  STATUS_DECLINED = Settings.ypb.transaction_statuses.declined
  STATUS_CANCELLED = Settings.ypb.transaction_statuses.cancelled

  ## INTERNAL ##
  STATUS_YPB_CANCELLED = "YPB_CANCELLED" # if transaction was declined
  STATUS_YPB_DECLINED = "YPB_DECLINED" # if transaction was declined
  STATUS_PAID = "PAID" # Fine has been paid
  STATUS_PAID_PARTIAL = "PAID_PARTIAL" # if some of the fees were paid
  STATUS_REJECTED_BY_ALMA = "ALMA_REJECTED" # all payments were rejected by alma
  STATUS_PROCESSING = "PROCESSING"
  STATUS_NEW = "NEW"

  STATUSES = [STATUS_PROCESSING, STATUS_PAID, STATUS_PAID_PARTIAL, STATUS_REJECTED_BY_ALMA,
              STATUS_APPROVED, STATUS_DECLINED, STATUS_CANCELLED ]

  ## RELATIONSHIPS ##
  belongs_to :user
  has_many :records, class_name: "PaymentRecord", foreign_key: "transaction_id"

  ## VALIDATIONS ##
  validates_presence_of :status
  validates_inclusion_of :status, in: [STATUS_APPROVED, STATUS_DECLINED, STATUS_CANCELLED,
                                        STATUS_NEW, STATUS_PROCESSING,
                                        STATUS_PAID, STATUS_PAID_PARTIAL,
                                        STATUS_REJECTED_BY_ALMA,
                                        STATUS_YPB_CANCELLED, STATUS_YPB_DECLINED ]

  ## CALLBACKS ##
  after_create :generate_new_order_id

  ## SCOPES ##
  scope :processing, -> { where(status: STATUS_PROCESSING )}
  scope :older_than, ->(time_from = 15.minutes.ago) { where("created_at <= ?", time_from) }
  scope :approved, -> { where(status: STATUS_APPROVED )}
  scope :paid, -> { where(status: STATUS_PAID )}
  scope :paid_partial, -> { where(status: STATUS_PAID_PARTIAL )}
  scope :rejected_by_alma, -> { where(status: STATUS_REJECTED_BY_ALMA) }
  scope :declined, -> { where(status: STATUS_DECLINED )}
  scope :cancelled, -> { where(status: STATUS_CANCELLED )}
  scope :stale, -> { where(status: STATUS_STALE )}
  scope :declined_or_cancelled, -> { declined.or(cancelled) }

  def mark_paid!
    return if status != STATUS_APPROVED

    if records.rejected.size == records.size
      update_attribute :status, STATUS_REJECTED_BY_ALMA
    elsif records.rejected.size > 0
       update_attribute :status, STATUS_PAID_PARTIAL
       update_attribute :alma_fines_paid_at, Date.current
    else
      update_attribute :status, STATUS_PAID
      update_attribute :alma_fines_paid_at, Date.current
    end
  end

  def mark_ypb_incomplete!
    return if status != STATUS_DECLINED || status != STATUS_CANCELLED
    update_attribute :status, STATUS_YPB_INCOMPLETE
  end

  def declined?
    status == STATUS_DECLINED
  end

  def cancelled?
    status == STATUS_CANCELLED
  end

  def approved?
    status == STATUS_APPROVED
  end

  def paid?
    status == STATUS_PAID
  end

  def paid_partial?
    status == STATUS_PAID_PARTIAL
  end

  def rejected_by_alma?
    status == STATUS_REJECTED_BY_ALMA
  end

  def ypb_incomplete?
    status == STATUS_YPB_CANCELLED || status == STATUS_YPB_DECLINED
  end

  def total_amount_fees
    total = 0
    records.each do |r|
      total = total + r.amount
    end

    return total
  end

  private
  def generate_new_order_id
    update_attribute :order_id, "#{id}-#{Time.now.to_i}"
  end
end

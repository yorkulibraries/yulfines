class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable,
  devise :database_authenticatable, :trackable, :rememberable, :validatable
  #devise :barcode_authenticatable, :validatable, :trackable

  ## VALIDATIONS ##
  validates_presence_of :yorku_id
  validates_format_of :email, allow_blank: true, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ #:with => Devise::email_regexp

  #validates_uniqueness_of :email, allow_blank: true,  message: "The email address is already in use."
  validates_uniqueness_of :yorku_id, message: "The YorkU ID is already in use."

  ## RELATIONSHIPS ##
  def alma_fees
    Alma::Fee.active.where(yorku_id: self[:yorku_id])
  end

  def paid_alma_fees
    Alma::Fee.paid.where(yorku_id: self[:yorku_id])
  end

  has_many :payment_transactions


  ## HELPER METHODS ##
  def initials
    "#{first_name.first}#{last_name.first if last_name}"
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    self[:became_admin_at] != nil
  end

  def make_admin!
    update became_admin_at: Date.current
  end

  def revoke_admin!
    update became_admin_at: nil
  end

  private
  ## CUSTOM VALIDATION
  def email_uniqueness
    if User.find_by_email(email) != nil
      errors.add(:email, "There is an account associated with this email already.")
    end
  end

  # Disable EMAIL Uniqueness Validation: rails 5.1+
  def will_save_change_to_email?
    false
  end

end

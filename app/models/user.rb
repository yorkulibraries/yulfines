class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :registerable, :recoverable,
  devise :database_authenticatable, :trackable, :lockable

  ## VALIDATIONS ##
  validates_presence_of :username
  validates_format_of :email, allow_blank: true, :with => Devise::email_regexp

  validates_uniqueness_of :yorku_id, allow_blank: true, case_sensitive: false
  validates_uniqueness_of :username, case_sensitive: false

  ## RELATIONSHIPS ##
  def alma_fees
    Alma::Fee.active.where(user_primary_id: self[:username])
  end

  def paid_alma_fees
    Alma::Fee.paid.where(user_primary_id: self[:username])
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
    self[:became_admin_at] != nil || (Rails.env.development? && id == 1)
  end

  def make_admin!
    update became_admin_at: Date.current
  end

  def revoke_admin!
    update became_admin_at: nil
  end

  def self.get_univ_id_from_alma_user(alma_user)
    alma_user.user_identifier.each do |i|
      if i['id_type']['value'] == 'UNIV_ID'
        return i['value']
      end
    end
    return nil
  end
end

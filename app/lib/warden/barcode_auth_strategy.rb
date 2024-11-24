require 'digest'
require 'devise/strategies/authenticatable'

class Warden::BarcodeAuthStrategy < Devise::Strategies::Authenticatable
  def valid?
    user_id && password
  end

  def authenticate!
    Rails.logger.debug "start BarcodeAuthStrategy.authenticate"

    resource = User.find_by_username user_id

    if Alma::User.authenticate(user_id: user_id, password: password)
      alma_user = Alma::User.find user_id

      if alma_user.nil?
        Rails.logger.debug "fail BarcodeAuthStrategy.authenticate no matching user in Alma for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      if alma_user.expiry_date.to_date < Date.current + 1
        Rails.logger.debug "fail BarcodeAuthStrategy.authenticate user expiry in Alma (#{alma_user.expiry_date}) for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      if alma_user.status['value'] != 'ACTIVE'
        Rails.logger.debug "fail BarcodeAuthStrategy.authenticate user status in Alma (#{alma_user.status}) for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      univ_id = User.get_univ_id_from_alma_user(alma_user)

      local_user_by_univ_id = User.find_by_yorku_id univ_id if univ_id
      local_user_by_username = User.find_by_username alma_user.primary_id

      if local_user_by_univ_id && local_user_by_username && local_user_by_univ_id.id != local_user_by_username.id
        Rails.logger.debug "Found 2 conflicting user records in db. ID: #{local_user_by_univ_id.id } and #{local_user_by_username.id }."
        Rails.logger.debug "fail BarcodeAuthStrategy.authenticate #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      local_user = local_user_by_univ_id ? local_user_by_univ_id : local_user_by_username

      # create in db if doesn't exist
      email = alma_user.email.kind_of?(Array) ? alma_user.email.first : alma_user.email
      if !local_user
        random = Digest::SHA256.hexdigest(rand().to_s)
        Rails.logger.debug "random generated password #{random}"
        local_user = User.create! username: alma_user.primary_id, password: random,
                      yorku_id: univ_id, email: email,
                      first_name: alma_user.first_name, last_name: alma_user.last_name
      else
        Rails.logger.debug "Updating username=#{alma_user.primary_id} yorku_id=#{univ_id} email=#{email}"
        local_user.username = alma_user.primary_id
        local_user.yorku_id = univ_id
        local_user.email = email
        local_user.save
      end

      Rails.logger.debug "success BarcodeAuthStrategy.authenticate #{user_id} - local user ID: #{local_user.id}"
      success!(local_user)
    else
      Rails.logger.debug "fail BarcodeAuthStrategy.authenticate #{user_id}"
      fail!(:invalid)
      return validate(resource) { false }
    end
  end

  def user_id
    params[:user][:username].strip unless (params[:user].nil? || params[:user][:username].nil?)
  end

  def password
    params[:user][:password].strip unless (params[:user].nil? || params[:user][:password].nil?)
  end
end
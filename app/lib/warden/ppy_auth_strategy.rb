require 'digest'
require 'devise/strategies/authenticatable'

class Warden::PpyAuthStrategy < Devise::Strategies::Authenticatable
  LOGIN = ['/ppy_login']
  LOGOUT = 'https://passportyork.yorku.ca/ppylogin/ppylogout'
  CYIN = 'HTTP_PYORK_CYIN'

  def valid?
    Warden::PpyAuthStrategy.py_authenticated(request)
  end

  def authenticate!
    Rails.logger.debug "start PpyAuthStrategy.authenticate"

    resource = User.find_by_yorku_id user_id

    if Warden::PpyAuthStrategy.py_authenticated(request)
      alma_user = Warden::PpyAuthStrategy.find_alma_user_matching_py_cyin(request)

      if alma_user.nil?
        Rails.logger.debug "fail PpyAuthStrategy.authenticate no matching user in Alma for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      if alma_user.expiry_date.to_date <= Date.current
        Rails.logger.debug "fail PpyAuthStrategy.authenticate user expiry in Alma (#{alma_user.expiry_date}) for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      if alma_user.status['value'] != 'ACTIVE'
        Rails.logger.debug "fail PpyAuthStrategy.authenticate user status in Alma (#{alma_user.status}) for #{user_id}"
        fail!(:invalid)
        return validate(resource) { false }
      end

      univ_id = ::User.get_univ_id_from_alma_user(alma_user)

      local_user_by_univ_id = User.find_by_yorku_id univ_id if univ_id
      local_user_by_username = User.find_by_username alma_user.primary_id

      if local_user_by_univ_id && local_user_by_username && local_user_by_univ_id.id != local_user_by_username.id
        Rails.logger.debug "Found 2 conflicting user records in db. ID: #{local_user_by_univ_id.id } and #{local_user_by_username.id }."
        Rails.logger.debug "fail PpyAuthStrategy.authenticate #{user_id}"
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
                      first_name: alma_user.first_name, last_name: alma_user.last_name,
                      auth_method: self.class.name
      else
        Rails.logger.debug "Updating username=#{alma_user.primary_id} yorku_id=#{univ_id} email=#{email}"
        local_user.username = alma_user.primary_id
        local_user.yorku_id = univ_id
        local_user.email = email
        local_user.auth_method = self.class.name
        local_user.save
      end

      Rails.logger.debug "success PpyAuthStrategy.authenticate - UNIV_ID: #{univ_id} == CYIN: #{user_id}, local user ID: #{local_user.id}"
      success!(local_user)
    else
      Rails.logger.debug "fail PpyAuthStrategy.authenticate - No PY Headers present"
      fail!(:invalid)
      return validate(resource) { false }
    end
  end

  def user_id
    return nil unless Warden::PpyAuthStrategy.py_authenticated(request)
    Warden::PpyAuthStrategy.py_authenticated_user_id(request)
  end

  def self.py_authenticated(req)
    return false unless LOGIN.include?(req.path)
    req.headers[CYIN] != nil && req.headers[CYIN].strip != ''
  end

  def self.py_authenticated_user_id(req)
    return nil unless Warden::PpyAuthStrategy.py_authenticated(req)
    req.headers[CYIN].strip
  end

  def self.find_alma_user_matching_py_cyin(req)
    return nil unless Warden::PpyAuthStrategy.py_authenticated(req)
    user_id = Warden::PpyAuthStrategy.py_authenticated_user_id(req)
    begin
      Rails.logger.debug "Looking for user in Alma with CYIN: #{user_id}"
      alma_user = Alma::User.find user_id
      univ_id = ::User.get_univ_id_from_alma_user(alma_user)

      # The PPY CYIN *MUST* match the UNIV_ID in Alma
      if univ_id != user_id
        Rails.logger.debug "Found a user in Alma, but UNIV_ID does NOT match. UNIV_ID: #{univ_id} != CYIN: #{user_id}"
        return nil
      end

      Rails.logger.debug "Found a user in Alma with UNIV_ID: #{univ_id} == CYIN: #{user_id}"
      return alma_user
    rescue
      Rails.logger.debug "Could not find any user in Alma with CYIN: #{user_id}"
    end
    return nil
  end

  def self.py_logout_url
    LOGOUT
  end

  def self.remove_py_header_if_not_valid(req)
    req.headers[CYIN] = nil unless Warden::PpyAuthStrategy.py_authenticated(req)
  end
end
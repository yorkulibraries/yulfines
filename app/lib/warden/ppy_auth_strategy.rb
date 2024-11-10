require 'digest'

class Warden::PpyAuthStrategy < Warden::Strategies::Base
  def valid?
    Warden::PpyAuthStrategy.py_authenticated(request)
  end

  def authenticate!
    Rails.logger.debug "start PpyAuthStrategy.authenticate"

    if Warden::PpyAuthStrategy.py_authenticated(request)
      alma_user = Warden::PpyAuthStrategy.find_alma_user_matching_py_cyin(request)

      if alma_user.nil?
        fail!("User not found in Alma") 
        return false
      end

      univ_id = ::User.get_univ_id_from_alma_user(alma_user)

      local_user = ::User.find_by_yorku_id univ_id

      # create  in db if doesn't exist
      if !local_user
        email = alma_user.email.kind_of?(Array) ? alma_user.email.first : alma_user.email
        random = Digest::SHA256.hexdigest(rand())
        Rails.logger.debug "random generated password #{random}"
        local_user = User.create! username: alma_user.primary_id, password: random,
                      yorku_id: univ_id, email: email,
                      first_name: alma_user.first_name, last_name: alma_user.last_name
      end

      Rails.logger.debug "success PpyAuthStrategy.authenticate - UNIV_ID: #{univ_id} == CYIN: #{user_id}"
      success!(local_user)
      return true
    else
      Rails.logger.debug "fail PpyAuthStrategy.authenticate - No PY Headers present"
      fail("Not yet authenticated by Passport York")
    end
    return false
  end

  def user_id
    return nil unless Warden::PpyAuthStrategy.py_authenticated(request)
    Warden::PpyAuthStrategy.py_authenticated_user_id(request)
  end

  def self.py_authenticated(req)
    return false unless Settings.app.auth.py_authenticated_paths.include?(req.path)
    header = Settings.app.auth.cas_header
    req.headers[header] != nil && req.headers[header].strip != ''
  end

  def self.py_authenticated_user_id(req)
    return nil unless Warden::PpyAuthStrategy.py_authenticated(req)
    header = Settings.app.auth.cas_header
    req.headers[header].strip
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
    Settings.app.auth.py_logout_url
  end

  def self.remove_py_header_if_not_valid(req)
    req.headers[Settings.app.auth.cas_header] = nil unless Warden::PpyAuthStrategy.py_authenticated(req)
  end
end
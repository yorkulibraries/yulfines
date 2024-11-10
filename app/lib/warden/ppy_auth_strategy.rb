require 'digest'

class Warden::PpyAuthStrategy < Warden::Strategies::Base
  def authenticate!
    Rails.logger.debug "start PpyAuthStrategy.authenticate"
    if ppy_present?
      user = nil
      begin
        Rails.logger.debug "Looking for user in Alma with CYIN: #{user_id}"
        user = Alma::User.find user_id
      rescue
        Rails.logger.debug "fail PpyAuthStrategy.authenticate - user not found in Alma with CYIN: #{user_id}"
        fail!("User not found in Alma")
        return false
      end

      univ_id = ::User.get_univ_id_from_alma_user(user)

      # The PPY CYIN *MUST* match the UNIV_ID in Alma to be authenticated
      if univ_id != user_id
        Rails.logger.debug "fail PpyAuthStrategy.authenticate - UNIV_ID: #{univ_id} != CYIN: #{user_id}"
        fail!("User not found in Alma") 
        return false
      end

      Rails.logger.debug "PpyAuthStrategy.authenticate - found user in Alma with UNIV_ID: #{univ_id} == CYIN: #{user_id}"

      local_user = ::User.find_by_yorku_id user_id

      # create  in db if doesn't exist
      if !local_user
        email = user.email.kind_of?(Array) ? user.email.first : user.email
        random = Digest::SHA256.hexdigest(rand().to_s)
        Rails.logger.debug "random generated password #{random}"
        local_user = User.create! username: user.primary_id, password: random,
                      yorku_id: univ_id, email: user.email,
                      first_name: user.first_name, last_name: user.last_name
      end

      Rails.logger.debug "success PpyAuthStrategy.authenticate - UNIV_ID: #{univ_id} == CYIN: #{user_id}"
      success!(local_user)
    else
      Rails.logger.debug "fail PpyAuthStrategy.authenticate - No PY Headers present"
      fail("Not yet authenticated by Passport York")
    end
  end

  def ppy_present?
    header = Settings.app.auth.cas_header
    request.headers[header] != nil && request.headers[header].strip != ''
  end

  def user_id
    header = Settings.app.auth.cas_header
    request.headers[header].strip
  end

end

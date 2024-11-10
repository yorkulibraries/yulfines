class Warden::PpyAuthStrategy < Warden::Strategies::Base
  def authenticate!
    Rails.logger.debug "start PpyAuthStrategy.authenticate"
    if ppy_present?
      user = nil
      begin
        Rails.logger.debug "Looking for user in Alma with CYIN: #{user_id}"
        user = Alma::User.find user_id
      rescue
        Rails.logger.debug "fail PpyAuthStrategy.authenticate - User not found in Alma with CYIN: #{user_id}"
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

      local_user = ::User.find_by_yorku_id user_id

      # create  in db if doesn't exist
      if !local_user
        email = user.email.kind_of?(Array) ? user.email.first : user.email

        local_user = ::User.new username: user_id, password: nil,
                      yorku_id: user_id, email: email,
                      first_name: user.first_name, last_name: user.last_name
        local_user.save validate: false
      end
      local_user.username = user_id

      Rails.logger.debug "success PpyAuthStrategy.authenticate - UNIV_ID: #{univ_id} == CYIN: #{user_id}"
      success!(local_user)
    else
      Rails.logger.debug "fail PpyAuthStrategy.authenticate - No PY Headers present"
      fail("NO PPY DEFINED")
    end
  end

  def ppy_present?
    header = Settings.app.auth.cas_header
    request.headers[header] != nil
  end

  def user_id
    header = Settings.app.auth.cas_header
    request.headers[header]
  end

end

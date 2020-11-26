class Warden::PpyAuthStrategy < Warden::Strategies::Base
  def authenticate!

    if ppy_present?
      user = Alma::User.find user_id

      # create  in db if doesn't exist
      local_user = ::User.find_by_yorku_id user.primary_id

      if !local_user
        email = user.email.kind_of?(Array) ? user.email.first : user.email

        local_user = ::User.new username: user_id, password: nil,
                      yorku_id: user.primary_id, email: email,
                      first_name: user.first_name, last_name: user.last_name
        local_user.save validate: false
      end

      success!(local_user)
    else
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

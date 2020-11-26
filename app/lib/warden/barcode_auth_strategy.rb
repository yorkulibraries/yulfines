
class Warden::BarcodeAuthStrategy < Warden::Strategies::Base

  def user_id
    params[:user][:username]
  end

  def password
    params[:user][:password]
  end

  def valid?
    return if params[:user] == nil
    user_id || password
  end

  def authenticate!
    pp "I SHOULD BE SECOND"
    pp "HERE"
    if Alma::User.authenticate(user_id: user_id.strip, password: password)
      pp "I AM"
      user = Alma::User.find user_id

      # create  in db if doesn't exist
      local_user = User.find_by_yorku_id user.primary_id
      pp local_user
      if !local_user
        email = user.email.kind_of?(Array) ? user.email.first : user.email

        local_user = User.create! username: user_id, password: password,
                      yorku_id: user.primary_id, email: user.email,
                      first_name: user.first_name, last_name: user.last_name
      end

      success!(local_user)
    else
      puts "BARCODE: NOT AUTHENTICATED: #{user_id}"
      pp "NOT AUTHENTICATED"
      # Fail and move on to the other startegies (i.e. db authenticatable)
      fail!('Invalid barcode or password')
    end


  end
end

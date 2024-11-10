require 'digest'

class Warden::BarcodeAuthStrategy < Warden::Strategies::Base
  def valid?
    user_id && password
  end

  def authenticate!
    Rails.logger.debug "start BarcodeAuthStrategy.authenticate"
    if Alma::User.authenticate(user_id: user_id, password: password)
      user = Alma::User.find user_id

      univ_id = User.get_univ_id_from_alma_user(user)

      # Normally a user has a University ID, so we use that ID if it exists
      # patrons that don't belong to the university, the only ID they have is the barcode
      stable_id = univ_id ? univ_id : user_id

      # create  in db if doesn't exist
      local_user = User.find_by_yorku_id stable_id
      if !local_user
        email = user.email.kind_of?(Array) ? user.email.first : user.email
        random = Digest::SHA256.hexdigest(rand().to_s)
        Rails.logger.debug "random generated password #{random}"
        local_user = User.create! username: user.primary_id, password: random,
                      yorku_id: stable_id, email: user.email,
                      first_name: user.first_name, last_name: user.last_name
      end

      Rails.logger.debug "success BarcodeAuthStrategy.authenticate #{user_id}"
      success!(local_user)
    else
      Rails.logger.debug "fail BarcodeAuthStrategy.authenticate #{user_id}"
      fail!('Invalid barcode or password')
    end
  end

  def user_id
    params[:user][:username].strip unless (params[:user].nil? || params[:user][:username].nil?)
  end

  def password
    params[:user][:password].strip unless (params[:user].nil? || params[:user][:password].nil?)
  end
end
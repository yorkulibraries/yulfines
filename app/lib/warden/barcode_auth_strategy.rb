require 'digest'

class Warden::BarcodeAuthStrategy < Warden::Strategies::Base
  def valid?
    user_id && password
  end

  def authenticate!
    Rails.logger.debug "start BarcodeAuthStrategy.authenticate"
    if Alma::User.authenticate(user_id: user_id, password: password)
      alma_user = Alma::User.find user_id

      univ_id = User.get_univ_id_from_alma_user(alma_user)

      # Normally a user has a University ID, so we use that ID if it exists
      # patrons that don't belong to the university, the only ID they have is the barcode
      stable_id = univ_id ? univ_id : user_id

      # create  in db if doesn't exist
      local_user = User.find_by_yorku_id stable_id
      if !local_user
        email = alma_user.email.kind_of?(Array) ? alma_user.email.first : alma_user.email
        random = Digest::SHA256.hexdigest(rand().to_s)
        Rails.logger.debug "random generated password #{random}"
        local_user = User.create! username: alma_user.primary_id, password: random,
                      yorku_id: stable_id, email: email,
                      first_name: alma_user.first_name, last_name: alma_user.last_name
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
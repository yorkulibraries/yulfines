class Alma::FeeLoader

  def self.find_user(id)
    user = Alma::User.find id
  end

  def self.load_fees(yorku_id)
    user = Alma::User.find yorku_id
    user.fines.response["fee"]
  end

  def self.load_and_update_fees(yorku_id)
    update_internal_fees load_fees(yorku_id), yorku_id if yorku_id != nil
  end

  def self.update_internal_fees(json_fees, yorku_id)
    return if json_fees == nil

    mark_all_active_fees_as_stale(yorku_id)

    fee_ids = []
    json_fees.each do |fee|
      alma_fee = parse_alma_fee(fee, yorku_id)
      fee_ids << alma_fee.fee_id
      update_existing_or_create_new(alma_fee)
    end

  end


  def self.update_existing_or_create_new(fresh_alma_fee)
    existing = Alma::Fee.find_by_fee_id(fresh_alma_fee.fee_id)

    if existing
      existing.balance = fresh_alma_fee.balance
      existing.remaining_vat_amount = fresh_alma_fee.remaining_vat_amount

      existing.status_time = fresh_alma_fee.status_time
      existing.fee_status = fresh_alma_fee.fee_status
      existing.owner_id = fresh_alma_fee.owner_id
      existing.owner_description = fresh_alma_fee.owner_description

      #  existing.original_amount = fresh_alma_fee.original_amount
      #  existing.original_vat_amount = fresh_alma_fee.original_vat_amount

      existing.save
      return existing
    else
      fresh_alma_fee.save
      return fresh_alma_fee
    end

  end

  def self.mark_all_active_fees_as_stale(yorku_id)
    user = User.find_by_yorku_id yorku_id
    fees = user.alma_fees

    fees.each do |f|
      f.mark_as_stale!
    end
  end

  def self.clean_up_active_fees(fee_ids)
    fees = Alma::Fee.active.where.not("fee_id in (?)", fee_ids)
    pp fees.size
    fees.delete_all
  end

  ## HELPER METHODS TO PARSE RETURNING JSON STRUCTURE ##

  def self.parse_alma_fee(json_fee,  yorku_id)
    alma_fee = Alma::Fee.new yorku_id: yorku_id

    alma_fee.fee_id = get_val json_fee, :id
    alma_fee.fee_type = get_val json_fee, :type, :value
    alma_fee.fee_description = get_val json_fee, :type, :desc

    alma_fee.fee_status = get_val json_fee, :status, :value
    alma_fee.user_primary_id = get_val json_fee, :user_primary_id, :value

    alma_fee.balance = get_val json_fee, :balance

    alma_fee.remaining_vat_amount = get_val json_fee, :remaining_vat_amount
    alma_fee.original_amount = get_val json_fee, :original_amount
    alma_fee.original_vat_amount = get_val json_fee, :original_vat_amount
    alma_fee.creation_time = get_val json_fee, :creation_time
    alma_fee.status_time = get_val json_fee, :status_time
    alma_fee.owner_id = get_val json_fee, :owner, :value
    alma_fee.owner_description = get_val json_fee, :owner, :desc
    alma_fee.item_title = get_val json_fee, :title
    alma_fee.item_barcode = get_val json_fee, :barcode, :value

    return alma_fee
  end


  ## HELPER METHOD TO GET VALUES OUT OF THE HASH ##
  def self.get_val(obj, key1, key2 = nil)
    if key2 == nil
      obj[key1.to_s] rescue "n/a"
    else
      obj[key1.to_s][key2.to_s] rescue "n/a"
    end
  end
end

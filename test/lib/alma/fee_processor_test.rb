require 'test_helper'
require 'webmock/minitest'
require_relative 'responses_rack_app.rb'

class Alma::FeeProcessorTest < ActionDispatch::IntegrationTest



  # NOT TESTING GETTING FEES, as it is part of the alma gem and tested there.
  setup do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  teardown do
    WebMock.allow_net_connect!
  end

  should "Pay Alma Fee" do
    transaction = create :payment_transaction
    record = create :payment_record, payment_transaction: transaction, user: transaction.user

    processor = Alma::FeeProcessor.new

    ## ANY REQUEST IS GETTING PASSED, WEBMOCK DOESN'T WANT TO WORK WITH SPECIFICS, NOT SURE WHY ##
    stub_request(:post, /.*/).with(headers: processor.headers).to_rack(Alma::ResponsesRackApp)

    assert processor.pay_fee! record

  end

  should "use defaul Settings fee url or be able to change feel url if need be" do
    new_url = "https://somewhere_else"
    transaction = create :payment_transaction
    record = create :payment_record, payment_transaction: transaction, user: transaction.user

    processor = Alma::FeeProcessor.new
    prepared_url = Settings.alma.api.fee_url.sub("{{fee_id}}", record.fee.fee_id.to_s).sub("{{user_primary_id}}", record.yorku_id.to_s)

    assert_equal prepared_url, processor.prepare_url(Settings.alma.api.fee_url, record)

    # processor.fee_url = new_url
    # assert_equal new_url, processor.fee_url
  end

  # should "should prepare url by replacing fee and user id placeholders" do
  #   transaction = create :payment_transaction
  #   record = create :payment_record, payment_transaction: transaction, user: transaction.user
  #
  #   processor = Alma::FeeProcessor.new url: "https:://api/{{fee_id}}/{{user_primary_id}}"
  #   assert_equal "https:://api/#{record.fee.fee_id}/#{record.yorku_id}", processor.prepare_url()
  # end


  should "parse error" do
    transaction = create :payment_transaction
    record = create :payment_record, payment_transaction: transaction, user: transaction.user

    error = { "errorsExist"=>true,
              "errorList"=> { "error"=>
                  [ {"errorCode"=>"401665",
                    "errorMessage"=>"Fine not found",
                    "trackingId"=>"E01-3009162803-TBMSZ-AWAE283111069"}]
              },
              "result"=>nil
            }

    processor = Alma::FeeProcessor.new

    processor.parse_error error

    assert_equal error["errorList"]["error"].first["errorCode"], processor.error_code
    assert_equal error["errorList"]["error"].first["errorMessage"], processor.error_message
    assert_equal error["errorList"]["error"].first["trackingId"], processor.tracking_id
  end

  should "return proper paymen method based on transaction card type" do
    visa = create :payment_transaction, cardtype: "V"
    mc = create :payment_transaction, cardtype: "M"

    record = create :payment_record, payment_transaction: visa

    processor = Alma::FeeProcessor.new
    assert_equal "CREDIT_CARD", processor.pay_method(record)
    assert_equal processor.pay_params(record)[:method], "CREDIT_CARD"

    record = create :payment_record, payment_transaction: mc
    assert_equal "CHECK", processor.pay_method(record)
    assert_equal processor.pay_params(record)[:method], "CHECK"

  end

  should "return proper pay params from record" do
    t = create :payment_transaction, cardtype: "V", refnum: "123"
    record = create :payment_record, payment_transaction: t

    processor = Alma::FeeProcessor.new

    params = processor.pay_params record

    assert_equal params[:user_type_id], "all_unique"
    assert_equal params[:op], "pay"
    assert_equal params[:amount], record.amount
    assert_equal params[:method], "CREDIT_CARD"
    assert_equal params[:reason], "Paying The Fee"
    assert_equal params[:comment], "#{record.user.name} is paying via YU Payment Broker"
    assert_equal params[:external_transaction_id], t.refnum
        
  end
end

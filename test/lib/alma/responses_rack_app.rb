require 'sinatra/base'

class Alma::ResponsesRackApp < Sinatra::Base


  #almaws/v1/users/1112393939/fees/1
  post '/almaws/v1/users/:user_primary_id/fees/:fee_id' do
    paid_response
  end


  private

  def paid_response()
    content_type :json
    status 200
    
    { "id" => "12345678910",
       "type" => { "value" => "OVERDUEFINE", "desc" => "Overdue fine" },
       "status" => { "value" => "CLOSED", "desc" => "Closed" },
       "user_primary_id" => { "value" => "ID12345678910", "link" => "https://something.com" },
       "balance" => 0.0,
       "remaining_vat_amount" => 0.0,
       "original_amount" => 3.0,
       "original_vat_amount" => 0.0,
       "creation_time" => "2010-10-27T10:59:00Z",
       "status_time" => "2019-05-30T02:01:11.174Z",
       "comment" => "CALL_ITEMNUM: QP 355.2 P76 2000 | ITEM_COPYNUM: 4 | USER_ALT_ID: 102028607",
       "owner" => { "value" => "SCOTT", "desc" => "Scott Library" },
       "title" => "Principles of neural science / edited by Eric R. Kandel, James H. Schwartz, Thomas M. Jessell ; art direction by Sarah Mack and Jane Dodd.",
       "barcode" => { "value" => "39007047016860", "link" => "https://something.com" },
       "link" => "https://something.com"
     }.to_s
  end
end

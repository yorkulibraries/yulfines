Rails.application.routes.draw do





  # DEVISE setup
  devise_for :users

  ## FROM PRIMO Link
  get "/from_primo" => "from_primo#show"

  ## LOGIN VIA PASSPORT YORK
  get "/ppy_login" => "ppy_login#show"

  get "/home" => "home#show"

  ## LOAD FEES from ALMA
  get "alma/load_fees" => "alma/load_fees#index", as: :load_alma_fees

  ## REDIRECTOR to payment broker
  get "redirecting/to_payment_broker" => "redirectors/to_payment_broker#show", as: :redirect_to_payment_broker

  ## REDIRECTOR to alma fine payment
  get "redirecting/to_alma_fines" => "redirectors/to_alma_fines#show", as: :redirect_to_alma_fines

  ## POSTBACK From YPB
  resource :ypb_postback, only: :create, controller: "ypb_postback"

  ## PAYMENTS ##

  ## processing, creating transactions and records
  resources :process_payments, only: [:new, :create]

  ## details for completed transactions
  resources :transactions, only: [:index, :show]

  ## HOME ##
  root 'from_primo#show'

  ## REPORTS ##
  get "/reports" => "reports#index", as: :reports
  get "/reports/transaction/:id" => "reports/transactions#show", as: :report_transaction
  get "/reports/transaction/:id/logs" => "reports/transaction_logs#show", as: :report_transaction_log

  ## DUMMY ALMA API ##
  unless Rails.env.production?
    get "alma/dummy_api/:user_id/fees/" => "alma/dummy_fees_api#show", as: :alma_dummy_api_get_fees
    post "alma/dummy_api/:user_id/fees/:fee_id" => "alma/dummy_fees_api#update", as: :alma_dummy_api_fees
  end

end

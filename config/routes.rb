Rails.application.routes.draw do
  # DEVISE setup
  devise_for :users

  root 'root#show'
  get "/from_primo" => "root#show"

  ## LOGIN VIA PASSPORT YORK
  get "/ppy_login" => "ppy_login#show"
  get "/ppy_logout" => "ppy_login#logout"

  get "/home" => "home#show"
  get "/load_fees" => "home#load_fees"

  ## POSTBACK From YPB
  resource :ypb_postback, only: :create, controller: "ypb_postback"

  ## PAYMENTS ##

  ## processing, creating transactions and records
  resources :process_payments, only: [:new, :create]

  ## details for completed transactions
  resources :transactions, only: [:index, :show]

  ## REPORTS ##
  get "/reports" => "reports#index", as: :reports
  get "/reports/transaction/:id" => "reports/transactions#show", as: :report_transaction

  ## DUMMY ALMA API ##
  unless Rails.env.production?
    get "alma/dummy_api/:user_id/fees/" => "alma/dummy_fees_api#show", as: :alma_dummy_api_get_fees
    post "alma/dummy_api/:user_id/fees/:fee_id" => "alma/dummy_fees_api#update", as: :alma_dummy_api_fees
  end
end
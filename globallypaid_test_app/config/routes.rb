Rails.application.routes.draw do
  get 'payments/index'
  resources :payment_instruments
  resources :customers
  get 'welcome/index'

  root to: 'customers#index'
end

Rails.application.routes.draw do
  resources :payments
  resources :payment_instruments
  resources :customers
  get 'welcome/index'

  root to: 'customers#index'
end

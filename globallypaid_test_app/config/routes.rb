Rails.application.routes.draw do
  resources :payment_instruments
  resources :customers
  get 'welcome/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

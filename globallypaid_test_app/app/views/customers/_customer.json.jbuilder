json.extract! customer, :id, :id, :client_id, :client_customer_id, :password, :use_2fa, :country_code, :user_2fa_id, :user_email_code, :created, :updated, :deleted, :first_name, :last_name, :phone, :email, :created_at, :updated_at
json.url customer_url(customer, format: :json)

json.extract! payment_instrument, :id, :type, :client_id, :customer_id, :billing_contact, :created_at, :updated_at
json.url payment_instrument_url(payment_instrument, format: :json)

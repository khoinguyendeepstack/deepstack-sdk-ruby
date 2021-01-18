ENV['RAILS_ENV'] ||= 'test'
require_relative '../../config/environment'
require './config'

# Initialize the gateway
puts "Initializing the gateway..."
gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(@credentials)

# Creating a customer for testing
customer_data = {
    'client_customer_id' => '1484333',
    'first_name' => 'John',
    'last_name' => 'Doe'
}
puts "Creating new customer..."
response = gateway.create_customer(customer_data)
customer_id = response.params["id"]

puts "Creating payment instrument for customer"
paymentinstrument_data = {}
response = gateway.create_paymentinstrument(customer_id, paymentinstrument_data)
  
puts "Calling payment instrument list..."
response = gateway.list_paymentinstruments(response.params["id"])
puts "Response: " + response.inspect

puts "Deleting the payment instrument..."
response = gateway.delete_paymentinstrument(response.params["id"])
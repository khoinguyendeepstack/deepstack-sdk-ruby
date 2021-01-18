ENV['RAILS_ENV'] ||= 'test'
require_relative '../../config/environment'
require './config'


# Initialize the gateway
puts "Initializing the gateway..."
gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(@credentials)
  
puts "Calling customer list..."
response = gateway.list_customers()

puts "Response: " + response.inspect

puts "Creating new customer..."
customer_data = {
    'client_customer_id' => '1474777',
    'first_name' => 'Peco',
    'last_name' => 'Danajlovski'
  }
response = gateway.create(customer_data)

puts "Deleting the customer..."
customer_id = response.params["id"]

response = gateway.delete_customer(customer_id)
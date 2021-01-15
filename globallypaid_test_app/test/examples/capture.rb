ENV['RAILS_ENV'] ||= 'test'
require_relative '../../config/environment'
require './config'

# Initialize the gateway
puts "Initializing the gateway..."
gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(@credentials)

credit_card = credit_card_gp('4000100011112224')

auth = gateway.authorize(500, credit_card, customer_data)
puts "Auth: #{auth.inspect}"

response = gateway.capture(500, auth.authorization)

puts "Response: " + response


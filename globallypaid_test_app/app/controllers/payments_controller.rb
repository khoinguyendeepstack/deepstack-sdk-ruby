class PaymentsController < ApplicationController

  # We are not using session data so it's safe to skip authenticity checks
  skip_forgery_protection

  def index
    auth = @gateway.authorize(@amount, @credit_card, @options)
    @gateway.capture(@amount, auth.authorization)
  end

  def create
    puts "Params: " + params.inspect
    @options.merge!({"id" => params["id"]})
    response = @gateway.charge(@amount, credit_card_gp("4111111111111111"), @options)
    
    puts "Response: #{response.inspect}"

    render :json => response.message
  end

end

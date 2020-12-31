require 'test_helper'

class RemoteGloballyPaidTest < Test::Unit::TestCase
  def setup
    @gateway = GloballyPaidGateway.new(fixtures(:globally_paid))

    @amount = 123
    @credit_card = credit_card_gp('4000100011112224')
    @declined_card = credit_card_gp('4000300011112220')
    @options = {
      billing_contact: billing_contact,
      # address: address,
      description: 'Store Purchase',
      client_customer_id: "1474687",
      client_transaction_id: "154896575",
      client_transaction_description: "ChargeWithToken for TesterXXX3",
      client_invoice_id: "758496",
      currency_code: "USD"
    }
  end

  def test_successful_charge
    response = @gateway.charge(@amount, @credit_card, @options)
    assert_success response
    assert_equal 'Approved', response.message
  end

  # def test_failed_purchase
  #   response = @gateway.purchase(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  # end

  def test_successful_authorize_and_capture
    auth = @gateway.authorize(@amount, @credit_card, @options)
    puts "Auth: #{auth.inspect}"
    assert_success auth

    assert capture = @gateway.capture(@amount, auth.authorization)
    assert_success capture
    assert_equal 'Approved', capture.message
  end

  def test_successful_list_customers
    customers = @gateway.list_customers

    assert_success customers
  end

  # def test_failed_authorize
  #   response = @gateway.authorize(@amount, @declined_card, @options)
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED AUTHORIZE MESSAGE', response.message
  # end

  # def test_partial_capture
  #   auth = @gateway.authorize(@amount, @credit_card, @options)
  #   assert_success auth

  #   assert capture = @gateway.capture(@amount-1, auth.authorization)
  #   assert_success capture
  # end

  # def test_failed_capture
  #   response = @gateway.capture(@amount, '')
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED CAPTURE MESSAGE', response.message
  # end

  def test_successful_refund
    purchase = @gateway.charge(@amount, @credit_card, @options)
    assert_success purchase

    assert refund = @gateway.refund(@amount, purchase.authorization)
    assert_success refund
    assert_equal 'Approved', refund.message
  end

  # def test_partial_refund
  #   purchase = @gateway.charge(@amount, @credit_card, @options)
  #   assert_success purchase

  #   assert refund = @gateway.refund(@amount-1, purchase.authorization)
  #   assert_success refund
  # end

  # def test_failed_refund
  #   response = @gateway.refund(@amount, '')
  #   assert_failure response
  #   assert_equal 'REPLACE WITH FAILED REFUND MESSAGE', response.message
  # end

  # def test_successful_verify
  #   response = @gateway.verify(@credit_card, @options)
  #   assert_success response
  #   assert_match %r{REPLACE WITH SUCCESS MESSAGE}, response.message
  # end

  # def test_failed_verify
  #   response = @gateway.verify(@declined_card, @options)
  #   assert_failure response
  #   assert_match %r{REPLACE WITH FAILED PURCHASE MESSAGE}, response.message
  # end

  # def test_dump_transcript
  #   # This test will run a purchase transaction on your gateway
  #   # and dump a transcript of the HTTP conversation so that
  #   # you can use that transcript as a reference while
  #   # implementing your scrubbing logic.  You can delete
  #   # this helper after completing your scrub implementation.
  #   dump_transcript_and_fail(@gateway, @amount, @credit_card, @options)
  # end

  # def test_transcript_scrubbing
  #   transcript = capture_transcript(@gateway) do
  #     @gateway.charge(@amount, @credit_card, @options)
  #   end
  #   transcript = @gateway.scrub(transcript)

  #   assert_scrubbed(@credit_card.number, transcript)
  #   assert_scrubbed(@credit_card.verification_value, transcript)
  #   assert_scrubbed(@gateway.options[:password], transcript)
  # end

  private

  def billing_contact
    billing_contact = {}
    billing_contact[:first_name] = "Test"
    billing_contact[:last_name] = "Tester"
    billing_contact[:address] = address
    billing_contact[:phone] = "614-340-0823"
    billing_contact[:email] = "test@test.com"
    billing_contact
  end

  def credit_card_gp(number)
    creditcard = {}
    creditcard[:number] = number # "4847182731147117"
    creditcard[:expiration] = "0627"
    creditcard[:cvv] = "361"
    creditcard
  end

end

require './test/test_helper'
require './lib/active_merchant/billing/gateways/Deepstack'
require 'yaml'
require 'json'

class DeepstackTest < Test::Unit::TestCase
    def setup
        hash = Psych.load_file('./test/fixtures.yml', aliases: true)
        # puts hash['deepstack']['publishable_api_key']
        @gateway = ActiveMerchant::Billing::Deepstack.new(:username => hash['deepstack']['username'],
                                :password => hash['deepstack']['password'],
                                :publishable_api_key => hash['deepstack']['publishable_api_key'],
                                :isProduction => hash['deepstack']['isProduction']) 
        # Fixture broken right now... no idea why
        # @gateway = GloballyPaidGateway.new(fixtures(:globally_paid))
        @credit_card = ActiveMerchant::Billing::CreditCard.new(
            :first_name => hash['deepstack']['firstName'],
            :last_name => hash['deepstack']['lastName'],
            :number => hash['deepstack']['number'],
            :month => hash['deepstack']['month'],
            :year => hash['deepstack']['year'],
            :verification_value => hash['deepstack']['cvv']
        )
        @options = {
            :card_billing_address => "123 Some Street",
            :card_billing_zipcode => '12345',
            :merchant_uuid => hash['deepstack']['merchant_uuid']
        }
    end

    def test_productionURL
        assert @gateway.get_url("createPaymentInstrument") == "https://api.deepstacknightly.io/CometAPI/PaymentInstrument/create"
    end

    def test_fakeCard_create
        response = @gateway.createPaymentInstrument(@credit_card, @options)
        # @payment_instrument_uuid = response.params["response"]["payment_instrument_uuid"]
        # puts response.params["response"]["payment_instrument_uuid"]
        # puts JSON.generate(@options)
        # assert response.success?
        assert_success response
    end

    def test_fakeCard_get
        response = @gateway.createPaymentInstrument(@credit_card, @options)
        payment_instrument_uuid = response.params["response"]["payment_instrument_uuid"]
        # puts payment_instrument_uuid
        # getOptions = @options.merge({
        #     :payment_insrument_uuid => payment_instrument_uuid
        # })
        # puts getOptions
        # payment_instrument_uuid = response.params[:response][:payment_instrument_uuid]
        response = @gateway.getPaymentInstrument(payment_instrument_uuid, @options)
        # puts @payment_instrument_uuid

        assert_success response
        assert response.params["response"]["card_billing_zipcode"] == "12345"
    end

    # Test Authorization with card
    def test_authorize_card
        response = @gateway.authorize(1000, @credit_card, @options)
        # puts response.params
        assert_success response
        assert response.params["response"]["captured_amount"] == 1000

        noCapture = @options.merge({
            :capture => false
        })
        # puts noCapture
        response = @gateway.authorize(1000, @credit_card, noCapture)
        # puts response.params
        assert_success response
        assert response.params["response"]["captured_amount"] == 0

    end
    # Test authorization with token
    def test_authorize_token
        response = @gateway.createPaymentInstrument(@credit_card, @options)
        payment_instrument_uuid = response.params["response"]["payment_instrument_uuid"]

        response = @gateway.authorize(1000, payment_instrument_uuid, @options)
        assert_success response
        assert response.params["response"]["captured_amount"] == 1000

        noCapture = @options.merge({
            :capture => false
        })
        response = @gateway.authorize(1000, payment_instrument_uuid, noCapture)
        assert_success response
        assert response.params["response"]["captured_amount"] == 0

    end

    def test_authorize_withShipping
        shipping_contact = {
            :contact_name => "test",
            :contact_address => "123 Some Street",
            :contact_city => "some city",
            :contact_state => "CA",
            :contact_postal_code => "12345",
            :contact_phone => "12346",
            :contact_email => "some email"
        }
        optionShipping = @options.merge({
            :shipping_contact => shipping_contact
        })
        response = @gateway.authorize(1000, @credit_card, optionShipping)

        assert_success response
    end

    # TODO: Waiting on working Postman tests for: Refund, void, capture

end
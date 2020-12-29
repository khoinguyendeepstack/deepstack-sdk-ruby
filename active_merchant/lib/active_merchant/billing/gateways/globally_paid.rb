require 'json'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class GloballyPaidGateway < Gateway
      self.test_url = 'https://qa.transactions.globallypaid.com/api'
      self.live_url = 'https://transactions.globallypaid.com/api'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'https://globallypaid.com/'
      self.display_name = 'Globally Paid SDK'

      # Set the money format to cents
      self.money_format = :cents


      # TODO
      STANDARD_ERROR_CODE_MAPPING = {}

      # Public: Create a new Globally Paid gateway.
      #
      # options - A hash of options:
      #           :publishable_api_key  - Publishable API key
      #           :app_id               - Application ID
      #           :shared_secret        - Shared secret
      def initialize(options={})
        requires!(options, :publishable_api_key, :app_id, :shared_secret, :sandbox)
        @publishable_api_key, @app_id, @shared_secret = options.values_at(:publishable_api_key, :app_id, :shared_secret)
        super
      end

      def charge(money, payment, options={})
        post = {}
        add_token(post)
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('sale', post)
      end

      def authorize(money, payment, options={})
        post = {}
        add_token(post)
        add_invoice(post, money, options)
        save_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('authonly', post)
      end

      def capture(money, authorization, options={})
        post = init_post(options)
        add_invoice(post, money, options)
        add_charge(post, authorization)
        commit('capture', post)
      end

      def refund(money, authorization, options={})
        post = init_post(options)
        add_invoice(post, money, options)
        add_charge(post, authorization)        
        commit('refund', post)
      end

      def void(authorization, options={})
        commit('void', post)
      end

      def list_customers()
        commit('list_customers')
      end

      def create_customer(customer, options={})
        commit('create_customer', options)
      end

      def get_customer(customer_id)
        commit('get_customer', customer_id)
      end

      def update_customer(customer_id, options={})
        commit('update_customer', options)
      end

      def delete_customer(customer_id)
        commit('delete_customer', customer_id)
      end

      def list_paymentinstruments()
        commit('list_paymentinstruments')
      end

      def create_paymentinstrument(paymentinstrument, options={})
        commit('create_paymentinstrument', options)
      end

      def get_paymentinstrument(paymentinstrument_id)
        commit('get_customer', customer_id)
      end

      def update_paymentinstrument(paymentinstrument_id, options={})
        commit('update_paymentinstrument', options)
      end

      def delete_paymentinstrument(paymentinstrument_id)
        commit('delete_paymentinstrument', paymentinstrument_id)
      end      

      def verify(credit_card, options={})
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(100, credit_card, options) }
          r.process(:ignore_result) { void(r.authorization, options) }
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def init_post(options = {})
        post = {}
      end

      def add_charge(post, authorization)
        post[:charge] = authorization
      end

      def add_hmac_header(post)
        puts "Shared secret: #{@shared_secret}"
        puts "App ID: #{@app_id}"
        uuid = SecureRandom.uuid
        secret_decoded = Base64.strict_decode64(@shared_secret)
        hash_in_base64 = Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', secret_decoded, JSON.generate(post)))
        # puts "Hash in Base64: #{hash_in_base64}"
        hmac_string = "#{@app_id}:POST:#{uuid.to_s}:#{hash_in_base64}"
        # puts "HMAC String: #{hmac_string}"
        hmac_encoded = Base64.strict_encode64(hmac_string)
        # puts "HMAC Encoded: #{hmac_encoded}"
        {'hmac' => hmac_encoded}
      end

      def headers
        {
          'Authorization' => "Bearer #{@publishable_api_key}",
          'Accept' => 'text/plain',
          'Content-Type' => 'application/json-patch+json'
        }
      end      

      def add_customer_data(post, options)
        post[:billing_contact] = options[:billing_contact]
      end

      def add_address(post, creditcard, options)
        address = {}
        address[:line_1] = "123 Main St"
        address[:city] = "NYC"
        address[:state] = "NY"
        address[:postal_code] = "92657"
        address[:country] = "United States"     
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        # post[:currency] = (options[:currency] || currency(money))
      end

      def add_payment(post, payment)
        post[:client_customer_id] = "1474687"
        post[:capture] = true
        post[:rescurring] = false
        post[:currency_code] = "USD"
        post[:client_transaction_id] = "154896575"
        post[:client_transaction_description] = "ChargeWithToken for TesterXXX3"
        post[:client_invoice_id] = "758496"
        post[:avs] = false
        post[:user_agent] = nil
        post[:browser_header] = nil
        post[:save_payment_instrument] = true
      end

      def save_payment(post, payment)
        post[:client_customer_id] = "1474687"
        post[:capture] = false
        post[:rescurring] = false
        post[:currency_code] = "USD"
        post[:client_transaction_id] = "154896575"
        post[:client_transaction_description] = "ChargeWithToken for TesterXXX3"
        post[:client_invoice_id] = "758496"
        post[:avs] = false
        post[:user_agent] = nil
        post[:browser_header] = nil
        post[:save_payment_instrument] = false      
      end

      def parse(body)
        JSON.parse(body)
      end

      def commit(action, parameters)
        response = parse(ssl_post(url(action), post_data(action, parameters), headers.merge(add_hmac_header(parameters))))

        puts "Response: #{response}"

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          # avs_result: AVSResult.new(code: response["some_avs_response_key"]),
          # cvv_result: CVVResult.new(response["some_cvv_response_key"]),
          test: test?,
          error_code: error_code_from(response)
        )
      end

      def url(action, authorization = nil)
        puts "Action: #{action}"
        uri_action = uri(action)
        puts "URI: #{uri_action}"
        test? ? "#{test_url}#{uri_action}" : "#{live_url}#{uri_action}"
      end      

      def uri(action)
        uri = "/v1"
        case action
        when "sale"
          uri + "/charge"
        when "authonly"
          uri + "/charge"
        when "capture"
          uri + "/capture"
        when "refund"
          uri + "/refund"
        when "void"
          uri + "/refund"
        when "list_customers"
          uri + "/customer"
        when "list_payment_instruments"
          uri + "/paymentinstrument/list"
        else
          uri + "/noaction"
        end
      end      

      def success_from(response)
        response[:response_code] != 201
      end

      def message_from(response)
        response['message']
      end

      def authorization_from(response)
        response['id']
      end

      def post_data(action, parameters = {})
        JSON.generate(parameters)
      end

      def add_token(post)
        # Fetch the token 
        token_url = 'https://qa.token.globallypaid.com/api/v1/Token'
        auth = {}
        payment_instrument = {}

        # Credit card model
        creditcard = {}
        creditcard[:number] = "4847182731147117"
        creditcard[:expiration] = "0627"
        creditcard[:cvv] = "361"

        # Address model
        address = {}
        address[:line_1] = "123 Main St"
        address[:city] = "NYC"
        address[:state] = "NY"
        address[:postal_code] = "92657"
        address[:country] = "United States"

        # Billing contact model
        billing_contact = {}
        billing_contact[:first_name] = "Test"
        billing_contact[:last_name] = "Tester"
        billing_contact[:address] = address
        billing_contact[:phone] = "614-340-0823"
        billing_contact[:email] = "test@test.com"

        # Payment instrument model
        payment_instrument[:type] = "creditcard"
        payment_instrument[:creditcard] = creditcard
        payment_instrument[:billing_contact] = billing_contact
        auth[:payment_instrument] = payment_instrument

        puts "Generated JSON: #{JSON.generate(auth)}"
          
        response = ssl_post(token_url, JSON.generate(auth), headers)

        puts "Response: #{response}"
        parsed = JSON.parse(response)

        post[:source] = parsed["id"]
      end


      def error_code_from(response)
        unless success_from(response)
          # TODO: lookup error code for this response
        end
      end
    end
  end
end

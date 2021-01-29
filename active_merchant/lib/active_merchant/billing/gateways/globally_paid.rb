require 'json'
require 'awesome_print'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class GloballyPaidGateway < Gateway
      self.test_url = 'https://qa.api.globallypaid.com/api'
      self.live_url = 'https://transactions.globallypaid.com/api'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'https://globallypaid.com/'
      self.display_name = 'Globally Paid SDK'

      # Set the money format to cents
      self.money_format = :cents

      # # TODO
      # STANDARD_ERROR_CODE_MAPPING = {}

      # Public: Create a new Globally Paid gateway.
      #
      #           options - A hash of options:
      #           :publishable_api_key  - Publishable API key
      #           :app_id               - Application ID
      #           :shared_secret        - Shared secret
      def initialize(options={})
        requires!(options, :publishable_api_key, :app_id, :shared_secret, :sandbox)
        @publishable_api_key, @app_id, @shared_secret = options.values_at(:publishable_api_key, :app_id, :shared_secret)
        super
      end

      # Charges specific amount of money
      #
      #   money - amount of money in cents
      #   payment - credit card or other instrument
      #   options - customer data
      def charge(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_customer_data(post, options)
        if !options["id"]
          add_token(post)
        else
          post[:source] = options["id"]
        end     
        add_token(post)

        commit('sale', post)
      end

      # Authorizes and prepares the transaction for capturing
      #
      #   money - amount of money in cents
      #   payment - credit card or other instrument
      #   options - customer data      
      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        save_payment(post, payment)
        add_customer_data(post, options)        
        add_token(post)

        commit('authonly', post)
      end

      # Capture authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction
      #   options - customer data        
      def capture(money, authorization, options={})
        post = init_post(options)
        add_invoice(post, money, options)
        add_charge(post, authorization)

        commit('capture', post)
      end

      # Refund authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction
      #   options - customer data        
      def refund(money, authorization, options={})
        post = init_post(options)
        add_invoice(post, money, options)
        add_charge(post, authorization)        
        commit('refund', post)
      end

      # Void authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction
      #   options - customer data             
      def void(authorization, options={})
        commit('void', post)
      end

      # List customers
      def list_customers()
        response = ssl_get('https://qa.api.globallypaid.com/api/v1/customer', headers)

        Response.new(
          response,
          authorization: authorization_from(response),
          test: test?,
        )        
      end

      # Create customer
      #
      #   customer - customer object
      def create_customer(customer)
        commit('create_customer', customer)
      end

      # Get the customer 
      #
      #   customer_id - the id of the customer
      def get_customer(customer_id)
        commit('get_customer', customer_id)
      end

      # Update customer
      #
      #   customer_id - the id of the customer
      #   options - upated data
      def update_customer(customer_id, options={})
        commit('update_customer', options)
      end

      # Delete customer
      #
      #   customer_id - the id of the customer
      def delete_customer(customer_id)
        response = ssl_request(:delete, "https://qa.api.globallypaid.com/api/v1/customer", customer_id, headers)

        Response.new(
          response,
          authorization: authorization_from(response),
          test: test?,
        )              
      end

      # List payment instruments      
      #
      #   customer_id - the id of the customer for whom we fetch the payment instruments
      def list_payment_instruments(customer_id)
        response = ssl_get("https://qa.api.globallypaid.com/api/v1/paymentinstrument/list/#{customer_id}", headers)

        Response.new(
          response,
          authorization: authorization_from(response),
          test: test?,
        )                
      end      

      # Create payment instrument for a customer
      #
      #   paymentinstrment - payment instrument object
      #   customer_id - the id of the payment instrument's customer
      def create_paymentinstrument(paymentinstrument)
        commit('create_paymentinstrument', paymentinstrument)
      end

      # Get the payment instrument
      #   paymentinstrument_id - the id of the payment instrument
      def get_paymentinstrument(paymentinstrument_id)
        commit('get_paymentinstrument', paymentinstrument_id)
      end

      # Update payment instrument
      #
      #   paymentinstrument_id - the id of the payment instrument
      #   options - upated data      
      def update_paymentinstrument(paymentinstrument_id, options={})
        commit('update_paymentinstrument', options)
      end

      # Delete payment instrument
      #
      #   paymentinstrument_id - the id of the payment instrument
      def delete_paymentinstrument(paymentinstrument_id) 
        response = ssl_request(:delete, "https://qa.api.globallypaid.com/api/v1/paymentinstrument/#{paymentinstrument_id}", nil, headers)

        Response.new(
          response,
          authorization: authorization_from(response),
          test: test?,
        )                
      end      

      # def verify(credit_card, options={})
      #   MultiResponse.run(:use_first_response) do |r|
      #     r.process { authorize(100, credit_card, options) }
      #     r.process(:ignore_result) { void(r.authorization, options) }
      #   end
      # end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def init_post(options = {})
        post = {}
        post
      end

      def add_charge(post, authorization)
        post[:charge] = authorization
      end

      def add_hmac_header(post)
        uuid = SecureRandom.uuid
        secret_decoded = Base64.strict_decode64(@shared_secret)
        hash_in_base64 = Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', secret_decoded, JSON.generate(post)))
        hmac_string = "#{@app_id}:POST:#{uuid.to_s}:#{hash_in_base64}"
        hmac_encoded = Base64.strict_encode64(hmac_string)
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
        post[:payment_instrument][:billing_contact] = options[:billing_contact]
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:client_customer_id] = options[:client_customer_id]
        post[:client_transaction_id] = options[:client_transaction_id]
        post[:client_transaction_description] = options[:client_transaction_description]
        post[:client_invoice_id] = options[:client_invoice_id]
        post[:currency_code] = options[:currency_code]
      end

      def add_payment(post, payment)
        payment_instrument = {}
        payment_instrument[:type] = "creditcard"
        payment_instrument[:creditcard] = payment

        post[:payment_instrument] = payment_instrument
        post[:capture] = true
        post[:recurring] = false
        post[:avs] = false
        post[:user_agent] = nil
        post[:browser_header] = nil
        post[:save_payment_instrument] = true
      end

      def save_payment(post, payment)
        payment_instrument = {}
        payment_instrument[:type] = "creditcard"
        payment_instrument[:creditcard] = payment

        post[:payment_instrument] = payment_instrument
        post[:capture] = false
        post[:recurring] = false
        post[:user_agent] = nil
        post[:browser_header] = nil
        post[:save_payment_instrument] = false   
      end

      def parse(body)
        JSON.parse(body)
      end

      def commit(action, parameters)
        begin
          hmac_header = add_hmac_header(parameters)
          response = parse(ssl_post(url(action), post_data(action, parameters), headers.merge(hmac_header)))
          puts "Sending..."
          ap parameters

          Response.new(
            success_from(response),
            message_from(response),
            response,
            authorization: authorization_from(response),
            avs_result: AVSResult.new(code: response["cvv_result"]),
            cvv_result: CVVResult.new(response["avs_result"]),
            test: test?,
            error_code: error_code_from(response)
          )
        rescue ResponseError => e
          puts "Caught error: "
          ap e.response.message
          puts "Headers:" 
          ap headers
          Response.new(
            e.response.code.to_i,
            e.response.message,
            {}
          )
        end
      end

      def url(action, authorization = nil)
        uri_action = uri(action)
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
        when "create_customer"
          uri + "/customer"
        when "list_payment_instruments"
          uri + "/paymentinstrument/list"
        when "create_paymentinstrument"
          uri + "/paymentinstrument"
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
        begin
          token_url = 'https://qa.api.globallypaid.com/api/v1/token'
          response = ssl_post(token_url, JSON.generate(post), headers)
          parsed = JSON.parse(response)
          post[:source] = parsed["id"]
        rescue ResponseError => e 
          puts "Post: "
          ap post
          puts "Headers: "
          ap headers
          ap e.response.message
        end
      end

      def error_code_from(response)
        unless success_from(response)
          response.code.to_i
        end
      end
    end
  end
end

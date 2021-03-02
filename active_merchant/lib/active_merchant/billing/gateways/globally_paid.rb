require 'json'
require 'awesome_print'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class GloballyPaidGateway < Gateway
      self.test_url = 'https://sandbox.api.globallypaid.com/api'
      self.live_url = 'https://api.globallypaid.com/api'

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
      #           :sandbox              - use sanbox url? (true or false)
      def initialize(options={})
        requires!(options, :publishable_api_key, :app_id, :shared_secret, :sandbox)
        @publishable_api_key, @app_id, @shared_secret, @sandbox = options.values_at(:publishable_api_key, :app_id, :shared_secret, :sandbox)
        super
      end

      # Charges specific amount of money
      #
      #   money - amount of money in cents
      #   payment - paymnent_instrument_id or CC structure
      #   options - customer data
      def purchase(money, payment, options={})
        post = {}
        add_invoice(post, options)
        add_payment_data(post, options)
        add_payment(post, payment)
        add_amount(post, money)

        post[:capture] = true

        commit('sale', post)
      end

      # Authorizes and prepares the transaction for capturing
      #
      #   money - amount of money in cents
      #   source - paymnent_instrument_id
      #   options - customer data      
      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, options)
        add_payment_data(post, options)
        add_payment(post, payment)
        add_amount(post, money)

        post[:capture] = false

        commit('authorization', post)
      end

      # Capture authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction id
      #   options - customer data        
      def capture(money, authorization, options={})
        post = {}
        add_charge(post, authorization)
        add_amount(post, money)

        commit('capture', post)
      end

      # Refund authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction id
      #   options - customer data        
      def refund(money, authorization, options={})
        post = {}
        add_charge(post, authorization)
        add_amount(post, money)
        
        post[:reason] = options[:reason]

        commit('refund', post)
      end

      # Void authorized transaction
      #
      #   money - amount of money in cents
      #   authorization - authorized transaction id
      #   options - customer data        
      def void(money, authorization, options={})
        ret = refund(money, authorization, options)
        ret
      end

      # List customers
      def list_customers()
        # response = ssl_get('https://qa.api.globallypaid.com/api/v1/customer', headers)
        response = ssl_get(get_url("list_customers"), headers)

        Response.new(
          response,
          authorization: authorization_from(response)
        )        
      end

      # Create customer
      #
      #   customer - customer object
      def create_customer(customer)
        commit("customer", customer)
      end

      # Get the customer 
      #
      #   customer_id - the id of the customer
      def get_customer(customer_id)
        ap get_url("customer") + '/' + customer_id

        response = ssl_get(get_url("customer") + "/" + customer_id, headers)
        # commit('customer', customer_id)
      end

      # Update customer
      #
      #   customer_id - the id of the customer
      #   options - upated data
      def update_customer(customer_id, options={})
        commit_put('customer', options, customer_id)
      end

      # Delete customer
      #
      #   customer_id - the id of the customer
      def delete_customer(customer_id) 
        hmac_header = add_hmac_header_delete(customer_id)
        merged_headers = headers.merge(hmac_header)

        response = ssl_request(:delete, get_url("customer") + "/" + customer_id, "", merged_headers)

        Response.new(
          response,
          authorization: authorization_from(response),
        )              
      end

      # List payment instruments      
      #
      #   customer_id - the id of the customer for whom we fetch the payment instruments
      def list_payment_instruments(customer_id)
        # response = ssl_get("https://qa.api.globallypaid.com/api/v1/paymentinstrument/list/#{customer_id}", headers)
        response = ssl_get(get_url("list_payment_instruments") + "/" + customer_id, headers)

        Response.new(
          response,
          authorization: authorization_from(response),
        )                
      end      

      # Create payment instrument for a customer
      #
      #   paymentinstrment - payment instrument object
      #   customer_id - the id of the payment instrument's customer
      def create_paymentinstrument(paymentinstrument)
        commit('paymentinstrument', paymentinstrument)
      end

      # Get the payment instrument
      #   paymentinstrument_id - the id of the payment instrument
      def get_paymentinstrument(paymentinstrument_id)
        commit('paymentinstrument', paymentinstrument_id)
      end

      # Update payment instrument
      #
      #   paymentinstrument_id - the id of the payment instrument
      #   options - upated data      
      def update_paymentinstrument(paymentinstrument_id, options={})
        commit_put('paymentinstrument', options, paymentinstrument_id)
      end

      # Delete payment instrument
      #
      #   paymentinstrument_id - the id of the payment instrument
      def delete_paymentinstrument(paymentinstrument_id) 
        hmac_header = add_hmac_header_delete(paymentinstrument_id)
        merged_headers = headers.merge(hmac_header)

        response = ssl_request(:delete, get_url("paymentinstrument") + "/" + paymentinstrument_id, "", merged_headers)

        Response.new(
          response,
          authorization: authorization_from(response),
        )                
      end      

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

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

      def add_hmac_header_delete(post)
        uuid = SecureRandom.uuid
        secret_decoded = Base64.strict_decode64(@shared_secret)
        hash_in_base64 = Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', secret_decoded, ""))
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

      def add_invoice(post, options)
        post[:client_customer_id] = options[:client_customer_id]
        post[:client_transaction_id] = options[:client_transaction_id]
        post[:client_transaction_description] = options[:client_transaction_description]
        post[:client_invoice_id] = options[:client_invoice_id]
        post[:currency_code] = options[:currency_code]
        post[:country_code] = options[:country_code]
      end

      def add_payment(post, payment)
        payment_instrument = {}
        payment_instrument[:type] = "creditcard"
        payment_instrument[:creditcard] = payment

        post[:payment_instrument] = payment_instrument
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

      def add_payment_data(post, options)
        post[:cof_type] = options[:cof_type]
        post[:avs] = options[:avs]
        post[:cvv] = options[:cvv]
        post[:user_agent] = options[:user_agent]
        post[:browser_header] = options[:browser_header]
        post[:save_payment_instrument] = options[:save_payment_instrument]
        post[:session_id] = options[:session_id]
        post[:shipping_info] = options[:shipping_info]
        post[:fees] = options[:fees]
      end

      def add_payment(post, payment)
        post[:source] = payment
      end

      def add_amount(post, amount)
        post[:amount] = amount(amount)
      end

      def parse(body)
        JSON.parse(body)
      end

      def commit(action, parameters)
        begin
          hmac_header = add_hmac_header(parameters)
          merged_headers = headers.merge(hmac_header)
          response = parse(ssl_post(get_url(action), post_data(action, parameters), merged_headers))
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
          ap merged_headers
          puts "Body:"
          ap e.response.body
          Response.new(
            e.response.code.to_i,
            e.response.body,
            {}
          )
        end
      end

      def commit_put(action, parameters, id)
        begin
          hmac_header = add_hmac_header(parameters)
          merged_headers = headers.merge(hmac_header)
          response = parse(ssl_put(get_url(action) + "/" + id, post_data(action, parameters), merged_headers))
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
          ap merged_headers
          puts "Body:"
          ap e.response.body
          Response.new(
            e.response.code.to_i,
            e.response.body,
            {}
          )
        end
      end

      def ssl_put(endpoint, data, headers = {})
        ap "endpoint:"
        ap endpoint
        ssl_request(:put, endpoint, data, headers)
      end

      def get_url(action)
        uri_action = uri(action)

        if (@sandbox) 
          "#{test_url}#{uri_action}"
        else 
          "#{live_url}#{uri_action}"
        end
      end  

      def uri(action)
        uri = "/v1"
        case action
        when "sale"
          uri + "/charge"
        when "authorization"
          uri + "/charge"
        when "capture"
          uri + "/capture"
        when "refund"
          uri + "/refund"
        when "void"
          uri + "/refund"
        when "list_customers"
          uri + "/customer"
        when "customer"
          uri + "/customer"       
        when "list_payment_instruments"
          uri + "/paymentinstrument/list"
        when "paymentinstrument"
          uri + "/paymentinstrument"
        when "token"
          uri + "/token"
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

      def error_code_from(response)
        unless success_from(response)
          response.code.to_i
        end
      end

    end
  end
end

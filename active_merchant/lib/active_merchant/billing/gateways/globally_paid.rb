module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class GloballyPaidGateway < Gateway
      self.test_url = 'https://qa.transactions.globallypaid.com/api'
      self.live_url = 'https://transactions.globallypaid.com/api'
      # self.test_token_url = 'https://qa.token.globallypaid.com'
      # self.live_token_url = 'https://token.globallypaid.com'

      self.supported_countries = ['US']
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]

      self.homepage_url = 'https://globallypaid.com/'
      self.display_name = 'Globally Paid SDK'

      STANDARD_ERROR_CODE_MAPPING = {}

      # Test values      
      test_auth_credentials = {
        :publishable_api_key => 'T0FL5VDNQRK0V6H1Z6S9H2WRP8VKIVWO', 
        :app_id => '6652820b-6a7a-4d36-bc32-786e49da1cbd', 
        :shared_secret => 'ME1uVox0hrk7i87e7kbvnID38aC2U3X8umPH0D+BsVA=', 
        :sandbox => true}

      def initialize(options={})
        requires!(options, :publishable_api_key, :app_id, :shared_secret, :sandbox)
        super
      end

      def purchase(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('sale', post)
      end

      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('authonly', post)
      end

      def capture(money, authorization, options={})
        commit('capture', post)
      end

      def refund(money, authorization, options={})
        commit('refund', post)
      end

      def void(authorization, options={})
        commit('void', post)
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

      # Generate HMAC signature from provided message and secret key with algorithm
      def hmac_digest(msg, secret_key, algorithm)
        mac = OpenSSL::HMAC.hexdigest(algorithm, secret_key, msg)
      end

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
      end

      def add_payment(post, payment)
      end

      def parse(body)
        {}
      end

      def commit(action, parameters)
        response = parse(ssl_post(url(action), post_data(action, parameters)))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          avs_result: AVSResult.new(code: response["some_avs_response_key"]),
          cvv_result: CVVResult.new(response["some_cvv_response_key"]),
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
          uri + "/capture"
        when "capture"
          uri + "/capture"
        when "refund"
          uri + "/refund"
        when "void"
          uri + "/cancel"
        else
          uri + "/noaction"
        end
      end      

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def post_data(action, parameters = {})
      end

      def error_code_from(response)
        unless success_from(response)
          # TODO: lookup error code for this response
        end
      end
    end
  end
end

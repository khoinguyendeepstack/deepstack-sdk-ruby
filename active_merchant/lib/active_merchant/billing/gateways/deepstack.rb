require 'json'
require 'awesome_print'
require 'base64'

require 'uri'
require 'net/http'
require 'net/https'

module ActiveMerchant #noDoc
    module Billing #nodoc
        class Deepstack < Gateway
            self.test_url = 'https://api.deepstacknightly.io'
            self.live_url = 'https://api2.deepstack.io'

            self.supported_countries = ['US']
            self.default_currency = 'USD'
            self.supported_cardtypes = [:visa, :master, :american_express, :discover]

            self.money_format = :cents

            # Creating a deepstack gateway
            #
            #           options - A hash of options:
            #           :publishable_api_key         - Publishable API key
            #           :username                    - Application ID
            #           :password                    - Shared secret
            #           :isProduction                - use sanbox url? (true or false)
            def initialize(options={})
                requires!(options, :publishable_api_key, :username, :password, :isProduction)
                @publishable_api_key, @username, @password, @isProduction = options.values_at(:publishable_api_key, :username, :password, :isProduction)
                super
            end

            # Return a token from a credit card
            # Need an address from them
            def createPaymentInstrument(creditCard, options={})
                post = {}
                addMerchantUUID(post, options)
                addPaymentInstrument(post, parseCard(creditCard, options))
                commit("createPaymentInstrument", post)

            end

            # Return card information from a token
            def getPaymentInstrument(paymentUUID, options={})
                post = {}
                addMerchantUUID(post,options)
                post[:payment_instrument_uuid] = paymentUUID
                commit("getPaymentInstrument", post)
            end

            # Authorize a request which can be done with either a card or token
            # Amount should be in cents
            # Shipping should be required in future
            def authorize(amount, payment, options={})
                post = {}
                # post[:capture] = options[:capture] || true
                post[:capture] = options.key?(:capture) ? options[:capture] : true
                addAmount(post, amount)
                addMerchantUUID(post, options)
                addPaymentInstrument(post, parseCard(payment, options))
                addCardOptions(post, options)
                addCustomFields(post,options)
                addReferenceNumber(post,options)

                # puts post
                commit("authorize", post)

            end

            #Capture
            def capture(amount, transaction_uuid, options={})
                post = {}
                addAmount(post, amount)
                addMerchantUUID(post, options)
                post[:card_transaction_uuid] = transaction_uuid

                commit("capture", post)
            end

            # Charge

            # Refund
            def refund(amount, transaction_uuid, options={})
                post = {}
                addAmount(post, amount)
                addMerchantUUID(post, options)
                addReferenceNumber(post, options)
                #this may need separate function if more than one type of token possible
                post[:transaction_uuid] = transaction_uuid

                commit("refund", post)
            end

            # Void
            def void(amount, transaction_uuid, options={})
                post = {}
                addAmount(post, amount)
                addMerchantUUID(post, options)
                #this may need separate function if more than one type of token possible
                post[:transaction_uuid] = transaction_uuid
                
                commit("void", post)
            end

            # Parsing card into deepstack acceptable format
            def parseCard(creditCard, options)
                # There are two card objects that have type card: token, credit card
                if creditCard.instance_of?(CreditCard)
                    {
                        :type => "card",
                        :card_name => creditCard.first_name + " " + creditCard.last_name,
                        :card_number => creditCard.number,
                        # "card_expiration" => creditCard.year.to_s + creditCard.month.to_s,
                        :card_expiration => "%02d%02d" % [creditCard.year, creditCard.month],
                        :card_cvv => creditCard.verification_value,
                        # TODO: Need to add fields for address here for deepstack in options field
                        :card_billing_address => options.key?(:card_billing_address) ? options[:card_billing_address] : "",
                        :card_billing_zipcode => options.key?(:card_billing_zipcode) ? options[:card_billing_zipcode] : ""


                    }
                else
                    {
                        :type => "card",
                        :payment_instrument_uuid => creditCard
                    }
                end
            end

            def addAmount(post, amount)
                post[:amount] = amount
            end

            def addCardOptions(post, options)
                cardOptions = {
                    :merchant_descriptor => options.key?(:merchant_descriptor) ? options[:merchant_descriptor] : ""
                }
                post[:card_options] = cardOptions
            end

            def addCustomFields(post, options)
                custom_fields = {
                    :source_reference => options.key?(:source_reference) ? options[:source_reference] : ""
                }
                post[:custom_fields] = custom_fields
            end

            def addMerchantUUID(post, options)
                post[:merchant_uuid] = options[:merchant_uuid]
            end

            def addPaymentInstrument(post, instrument)
                post[:payment_instrument] = instrument
            end

            def addReferenceNumber(post, options)
                post[:reference_number] = options.key?(:reference_number) ? options[:reference_number] : ""
            end


            # Sending a request
            def commit(action, parameters)
                begin
                    header = getHeaders()
                    hmac_header = getHMAC(parameters)
                    header = header.merge(hmac_header)
                    # Currently not working because SSL Certificate expired for nightly
                    # response = parse(ssl_post(get_url(action), post_data(parameters),header))
                    # puts "Sending..."
                    # ap parameters

                    # Checking if problem is SSL
                    uri = URI(get_url(action))
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    req = Net::HTTP::Post.new(uri.path, init_header = header)
                    # puts header
                    # req.basic_auth(@username, @password)
                    req.body = post_data(parameters)
                    # puts post_data(parameters)
                    response = https.request(req)
                    if response.code != "200"
                        raise "Bad request... code:  " + response.code + " message: " + response.message
                    end

                    # puts parse(response.body)

                    Response.new(
                        success_from(response),
                        message_from(response),
                        parse(response.body)
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

            def getHeaders()
                {
                    'Content-type' => 'application/json',
                    'Accept' => 'application/json',
                    'Endpoint-UUID' => @username,
                    'Authorization' => "Basic " + getAuthorization
                }
            end

            def getAuthorization()
                return Base64.strict_encode64("#{@username}:#{@password}")
            end

            def getHMAC(data)
                hmacHash = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', [@publishable_api_key].pack('H*'), JSON.generate(data)))
                {
                    'Content-Hash' => hmacHash
                }
            end

            # Get Request URL
            def get_url(action)
                uri_action = uri(action)
                # puts @isProduction
                if(@isProduction)
                    return "#{live_url}#{uri_action}"
                else
                    return "#{test_url}#{uri_action}"
                end
            end

            def uri(action)
                uri = ""
                case action
                when "createPaymentInstrument"
                    uri + "/CometAPI/PaymentInstrument/create"
                when "getPaymentInstrument"
                    uri + "/CometAPI/PaymentInstrument/get"
                when "authorize"
                    uri + "/CometAPI/Transaction/authorize"
                when "capture"
                    uri + "/CometAPI/Transaction/capture"
                when "refund"
                    uri + "/CometAPI/Transaction/refund"
                when "void"
                    uri + "/CometAPI/Transaction/void"
                else
                    uri + "invalid"
                end
            end

            def parse(data)
                JSON.parse(data)
            end

            def post_data(data)
                JSON.generate(data)
            end

            def success_from(response)
                return response.code != 200
            end

            def message_from(response)
                return response.body["status"]
            end
        end
    end
end
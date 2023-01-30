require 'json'
require 'awesome_print'

module ActiveMerchant #noDoc
    module Billing #nodoc
        class Deepstack < Gateway
            self.test_url = 'api.deepstacknightly.io'
            self.live_url = 'api.deepstacknightly.io'

            self.supported_countries = ['US']
            self.default_currency = 'USD'
            self.supported_cardtypes = [:visa, :master, :american_express, :discover]

            self.money_format = :cents

            # Creating a deepstack gateway
            #
            #           options - A hash of options:
            #           :publishable_api_key  - Publishable API key
            #           :app_id               - Application ID
            #           :shared_secret        - Shared secret
            #           :sandbox              - use sanbox url? (true or false)
            def initialize(options={})
                requires!(options, :publishable_api_key, :username, :password, :isProduction)
                @publishable_api_key, @username, @password, @isProduction = options.values_at(:publishable_api_key, :username, :password, :isProduction)
                puts(@username)
                super
            end

            # Get Request URL
            def get_url(action)
                uri_action = uri(action)
                puts @isProduction
                if(@isProduction)
                    return "#{live_url}#{uri_action}"
                else
                    return "#{test_url}#{uri_action}"
                end
            end

            def uri(action)
                uri = ""
                case action
                when "tokenize"
                    uri + "/CometAPI/PaymentInstrument/create"
                else
                    uri + "invalid"
                end
            end
        end
    end
end
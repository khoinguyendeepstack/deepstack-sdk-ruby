require './test/test_helper'
require './lib/active_merchant/billing/gateways/Deepstack'
require 'yaml'

class DeepstackTest < Test::Unit::TestCase
    def setup
        hash = Psych.load_file('./test/fixtures.yml', aliases: true)
        # puts hash['deepstack']['publishable_api_key']
        @gateway = Deepstack.new(:username => hash['deepstack']['username'],
                                :password => hash['deepstack']['password'],
                                :publishable_api_key => hash['deepstack']['publishable_api_key'],
                                :isProduction => hash['deepstack']['isProduction']) 
        # Fixture broken right now... no idea why
        # @gateway = GloballyPaidGateway.new(fixtures(:globally_paid))
    end

    def test_productionURL
        assert @gateway.get_url("tokenize") == "api.deepstacknightly.io/CometAPI/PaymentInstrument/create"
    end
end
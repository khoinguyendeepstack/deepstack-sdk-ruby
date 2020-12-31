require 'active_merchant'
class ApplicationController < ActionController::Base

    before_action :load_gateway

    private

    def load_gateway
        @gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(
            publishable_api_key: 'pk_test_pr9IokgZOcNd0YGLuW3unrvYvLoIkCCk',
            app_id: 'sk_test_3a164632-7951-4688-9d49-c9c5',
            shared_secret: 'u9TQah3vzkLjsiB/vB6+C9tuQhjvO8/3h+XB2YTaxr0=',
            sandbox: true            
        )
    end

end

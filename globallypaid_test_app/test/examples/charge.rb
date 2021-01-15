class ChargeExample

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
        @customer_id = 'cus_x3r5d8AiG0q2OVbpZdvRdQ'
    end

    
      
      

end

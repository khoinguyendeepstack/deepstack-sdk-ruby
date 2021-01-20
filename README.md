# Ruby SDK

The official GloballyPaid Ruby client library.


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Ruby SDK](#ruby-sdk)
  - [Requirements](#requirements)
  - [Bundler](#bundler)
  - [Manual Installation](#manual-installation)
- [Documentation](#documentation)
  - [Initialize the Client](#initialize-the-client)
  - [API](#api)
    - [Setting up a credit card](#setting-up-a-credit-card)
    - [Make a Instant Charge Sale Transaction](#make-a-instant-charge-sale-transaction)
    - [Payment requests](#payment-requests)
    - [Customer requests](#customer-requests)
    - [Payment instrument requests](#payment-instrument-requests)
  - [Testing](#testing)

<!-- /code_chunk_output -->


## Requirements

> Ruby 2.4.0 or later

> ActiveMerchant 1.110 or later

## Bundler

The library will be built as a gem and can be referenced in the Gemfile with:

```ruby
gem 'active-merchant-globally-paid-gateway'
```

## Manual Installation

The library can be also referenced locally

```ruby
gem 'active-merchant-globally-paid-gateway', :local => '/path/to/the/library'
```

or from a github repository:

```ruby
gem 'active-merchant-globally-paid-gateway', :github => 'user/repo'
```

# Documentation

## Initialize the Client

```ruby
gateway = ActiveMerchant::Billing::GloballyPaidGateway.new(
        :publishable_api_key => 'T0FL5VDNQRK0V6H1Z6S9H2WRP8VKIVWO', 
        :app_id => '6652820b-6a7a-4d36-bc32-786e49da1cbd', 
        :shared_secret => 'ME1uVox0hrk7i87e7kbvnID38aC2U3X8umPH0D+BsVA=', 
        :sandbox => true)
```

## API 

### Setting up a credit card 

Validating the card automatically detects the card type.

```ruby
credit_card = ActiveMerchant::Billing::CreditCard.new(
                :first_name         => 'Bob',
                :last_name          => 'Bobsen',
                :number             => '4242424242424242',
                :month              => '8',
                :year               => Time.now.year+1,
                :verification_value => '000')
```

### Make a Instant Charge Sale Transaction

```ruby
# ActiveMerchant accepts all amounts as Integer values in cents
amount = 1000  # $10.00

# The card verification value is also known as CVV2, CVC2, or CID
if credit_card.validate.empty?
  # Capture $10 from the credit card
  response = gateway.charge(amount, credit_card)

  if response.success?
    puts "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
  else
    raise StandardError, response.message
  end
end
```

### Payment requests

> Authorization

```ruby
# Authorizes and prepares the transaction for capturing
#
#   money - amount of money in cents
#   payment - credit card or other instrument
#   options - customer data      
auth = @gateway.authorize(@amount, @credit_card, @options)
```

> Capture

```ruby
# Capture authorized transaction
#
#   money - amount of money in cents
#   authorization - authorized transaction
#   options - customer data        
response = @gateway.capture(money, authorization, options={})
```

> Refund

```ruby
# Refund authorized transaction
#
#   money - amount of money in cents
#   authorization - authorized transaction
#   options - customer data        
response = gateway.refund(amount)
```

### Customer requests

> Listing customers

```ruby
# List customers
#
#   Returns a list of customer objects
customers = @gateway.list_customers()
```

> Fetching a customer

```ruby
# Get the customer 
#
#   customer_id - the id of the customer
customer = get_customer(customer_id)
```

> Creating a customer

```ruby
# Create customer
#
#   customer - customer object
#   
#   Returns the newly created customer object
customer = @gateway.create_customer(customer)
```

> Updating a customer

```ruby
# Update customer
#
#   customer_id - the id of the customer
#   options - updated customer fields
updated_customer = @gateway.update_customer(customer_id, options={})
```

> Deleting a customer

```ruby
# Delete customer
#
#   customer_id - the id of the customer
result = @gateway.delete_customer(customer_id)
```


### Payment instrument requests

> Listing payment instruments

```ruby
# List payment instruments      
#
#   customer_id - the id of the customer for whom we fetch the payment instruments
#
#   Return list of payment instrument objects
payment_instruments = @gateway.list_payment_instruments(customer_id)
```

> Fetching a payment instrument

```ruby
# Get the payment instrument
#
#   paymentinstrument_id - the id of the payment instrument
#
#   Returns the payment instrument object
payment_instrument = @gateway.get_paymentinstrument(paymentinstrument_id)
```

> Creating a payment instrument

```ruby
# Create payment instrument for a customer
#
#   paymentinstrment - payment instrument object
#   customer_id - the id of the payment instrument's customer
#   
#   Returns the newly created payment instrument object
payment_instrument = @gateway.create_paymentinstrument(paymentinstrument, customer_id)
```

> Updating a payment instrument
```ruby
# Update payment instrument
#
#   paymentinstrument_id - the id of the payment instrument
#   options - updated fields
payment_instrument = @gateway.update_paymentinstrument(paymentinstrument_id, options={})
```

> Deleting a payment instrument

```ruby
# Delete payment instrument
#
#   paymentinstrument_id - the id of the payment instrument
#
#   Returns the result of the operation
result = @gateway.delete_paymentinstrument(paymentinstrument_id)
```

## Testing

There are two types of unit tests for each gateway.  The first are the normal unit tests, which test the normal functionality of the gateway, and use "Mocha":http://mocha.rubyforge.org/ to stub out any communications with live servers.

The second type are the remote unit tests.  These use real test accounts, if available, and communicate with the test servers of the payments gateway.  These are critical to having confidence in the implementation of the gateway.  If the gateway doesn't have a global public test account then you should remove your private test account credentials from the file before submitting your patch.

To run tests:

```bash
$ bundle install
$ bundle exec rake test:local   #Runs `test:units` and `rubocop`. All these tests should pass.
$ bundle exec rake test:remote  #Will not pass without updating test/fixtures.yml with credentials
```

To run a test suite individually:

```bash
$ bundle exec rake test:units TEST=test/unit/gateways/globally_paid_test.rb
$ bundle exec rake test:remote TEST=test/remote/gateways/remote_globally_paid_test.rb
```

To run a specific test case use the `-n` flag:

```bash
$ ruby -Itest test/remote/gateways/remote_globally_paid_test.rb -n test_successful_purchase
```

It is useful to work on remote tests first, both because they're less complex (no mocking/stubbing) and because you can capture the request/response easily which can then be copied to the unit tests. To capture the actual HTTP request sent and response received, use the `DEBUG_ACTIVE_MERCHANT` environment variable.

```bash
$ DEBUG_ACTIVE_MERCHANT=true ruby -Itest test/remote/gateways/remote_globally_paid_test.rb -n test_successful_purchase
<- "POST /api/v1/capture....
<- "<?xml version=\"1.0\" ..."
-> "HTTP/1.1 200 OK\r\n"
-> "Content-Type: text/xml;charset=ISO-8859-1\r\n"
-> "Content-Length: 954\r\n"
...
```






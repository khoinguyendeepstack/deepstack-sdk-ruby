# GloballyPaid Ruby SDK

The official GloballyPaid Ruby client library.

## Requirements

Ruby 2.4.0 or later

ActiveMerchant 1.110 or later

## Bundler

The library will be built as a gem and can be referenced in the Gemfile with:

```
gem 'active-merchant-globally-paid-gateway'
```

## Manual Installation

The library can be also referenced locally

```
gem 'active-merchant-globally-paid-gateway', :local => '/path/to/the/library'
```

or from a github repository:

```
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

## Charges

## Setting up a credit card 

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
  response = gateway.purchase(amount, credit_card)

  if response.success?
    puts "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
  else
    raise StandardError, response.message
  end
end
```

### Refund request 

```ruby
response = gateway.refund(amount)
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
$ ruby -Itest test/remote/gateways/remote_nab_transact_test.rb -n test_successful_purchase
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


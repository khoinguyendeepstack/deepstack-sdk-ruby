# frozen_string_literal: true

require "test_helper"

class Activemerchant::Globallypaid::GatewayTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Activemerchant::Globallypaid::Gateway.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end
end

require 'test_helper'

class PaymentInstrumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payment_instrument = payment_instruments(:one)
  end

  test "should get index" do
    get payment_instruments_url
    assert_response :success
  end

  test "should get new" do
    get new_payment_instrument_url
    assert_response :success
  end

  test "should create payment_instrument" do
    assert_difference('PaymentInstrument.count') do
      post payment_instruments_url, params: { payment_instrument: { billing_contact: @payment_instrument.billing_contact, client_id: @payment_instrument.client_id, customer_id: @payment_instrument.customer_id, type: @payment_instrument.type } }
    end

    assert_redirected_to payment_instrument_url(PaymentInstrument.last)
  end

  test "should show payment_instrument" do
    get payment_instrument_url(@payment_instrument)
    assert_response :success
  end

  test "should get edit" do
    get edit_payment_instrument_url(@payment_instrument)
    assert_response :success
  end

  test "should update payment_instrument" do
    patch payment_instrument_url(@payment_instrument), params: { payment_instrument: { billing_contact: @payment_instrument.billing_contact, client_id: @payment_instrument.client_id, customer_id: @payment_instrument.customer_id, type: @payment_instrument.type } }
    assert_redirected_to payment_instrument_url(@payment_instrument)
  end

  test "should destroy payment_instrument" do
    assert_difference('PaymentInstrument.count', -1) do
      delete payment_instrument_url(@payment_instrument)
    end

    assert_redirected_to payment_instruments_url
  end
end

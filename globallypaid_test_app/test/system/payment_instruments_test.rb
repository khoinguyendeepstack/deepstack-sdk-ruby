require "application_system_test_case"

class PaymentInstrumentsTest < ApplicationSystemTestCase
  setup do
    @payment_instrument = payment_instruments(:one)
  end

  test "visiting the index" do
    visit payment_instruments_url
    assert_selector "h1", text: "Payment Instruments"
  end

  test "creating a Payment instrument" do
    visit payment_instruments_url
    click_on "New Payment Instrument"

    fill_in "Billing contact", with: @payment_instrument.billing_contact
    fill_in "Client", with: @payment_instrument.client_id
    fill_in "Customer", with: @payment_instrument.customer_id
    fill_in "Type", with: @payment_instrument.type
    click_on "Create Payment instrument"

    assert_text "Payment instrument was successfully created"
    click_on "Back"
  end

  test "updating a Payment instrument" do
    visit payment_instruments_url
    click_on "Edit", match: :first

    fill_in "Billing contact", with: @payment_instrument.billing_contact
    fill_in "Client", with: @payment_instrument.client_id
    fill_in "Customer", with: @payment_instrument.customer_id
    fill_in "Type", with: @payment_instrument.type
    click_on "Update Payment instrument"

    assert_text "Payment instrument was successfully updated"
    click_on "Back"
  end

  test "destroying a Payment instrument" do
    visit payment_instruments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Payment instrument was successfully destroyed"
  end
end

require "application_system_test_case"

class CustomersTest < ApplicationSystemTestCase
  setup do
    @customer = customers(:one)
  end

  test "visiting the index" do
    visit customers_url
    assert_selector "h1", text: "Customers"
  end

  test "creating a Customer" do
    visit customers_url
    click_on "New Customer"

    fill_in "Client customer", with: @customer.client_customer_id
    fill_in "Client", with: @customer.client_id
    fill_in "Country code", with: @customer.country_code
    fill_in "Created", with: @customer.created
    fill_in "Deleted", with: @customer.deleted
    fill_in "Email", with: @customer.email
    fill_in "First name", with: @customer.first_name
    fill_in "Id", with: @customer.id
    fill_in "Last name", with: @customer.last_name
    fill_in "Password", with: @customer.password
    fill_in "Phone", with: @customer.phone
    fill_in "Updated", with: @customer.updated
    check "Use 2fa" if @customer.use_2fa
    fill_in "User 2fa", with: @customer.user_2fa_id
    fill_in "User email code", with: @customer.user_email_code
    click_on "Create Customer"

    assert_text "Customer was successfully created"
    click_on "Back"
  end

  test "updating a Customer" do
    visit customers_url
    click_on "Edit", match: :first

    fill_in "Client customer", with: @customer.client_customer_id
    fill_in "Client", with: @customer.client_id
    fill_in "Country code", with: @customer.country_code
    fill_in "Created", with: @customer.created
    fill_in "Deleted", with: @customer.deleted
    fill_in "Email", with: @customer.email
    fill_in "First name", with: @customer.first_name
    fill_in "Id", with: @customer.id
    fill_in "Last name", with: @customer.last_name
    fill_in "Password", with: @customer.password
    fill_in "Phone", with: @customer.phone
    fill_in "Updated", with: @customer.updated
    check "Use 2fa" if @customer.use_2fa
    fill_in "User 2fa", with: @customer.user_2fa_id
    fill_in "User email code", with: @customer.user_email_code
    click_on "Update Customer"

    assert_text "Customer was successfully updated"
    click_on "Back"
  end

  test "destroying a Customer" do
    visit customers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Customer was successfully destroyed"
  end
end

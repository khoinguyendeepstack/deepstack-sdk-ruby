require 'test_helper'

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
  end

  test "should get index" do
    get customers_url
    assert_response :success
  end

  test "should get new" do
    get new_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference('Customer.count') do
      post customers_url, params: { customer: { client_customer_id: @customer.client_customer_id, client_id: @customer.client_id, country_code: @customer.country_code, created: @customer.created, deleted: @customer.deleted, email: @customer.email, first_name: @customer.first_name, id: @customer.id, last_name: @customer.last_name, password: @customer.password, phone: @customer.phone, updated: @customer.updated, use_2fa: @customer.use_2fa, user_2fa_id: @customer.user_2fa_id, user_email_code: @customer.user_email_code } }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should show customer" do
    get customer_url(@customer)
    assert_response :success
  end

  test "should get edit" do
    get edit_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    patch customer_url(@customer), params: { customer: { client_customer_id: @customer.client_customer_id, client_id: @customer.client_id, country_code: @customer.country_code, created: @customer.created, deleted: @customer.deleted, email: @customer.email, first_name: @customer.first_name, id: @customer.id, last_name: @customer.last_name, password: @customer.password, phone: @customer.phone, updated: @customer.updated, use_2fa: @customer.use_2fa, user_2fa_id: @customer.user_2fa_id, user_email_code: @customer.user_email_code } }
    assert_redirected_to customer_url(@customer)
  end

  test "should destroy customer" do
    assert_difference('Customer.count', -1) do
      delete customer_url(@customer)
    end

    assert_redirected_to customers_url
  end
end

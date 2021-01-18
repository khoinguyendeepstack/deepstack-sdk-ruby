require 'json'

class CustomersController < ApplicationController

  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index    
    result = @gateway.list_customers
    @customers = JSON.parse(result.success?)
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create    
    @gateway.create_customer(customer_params.to_h)

    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully created.' }
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @gateway.create_customer(customer_params.to_h)

    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully created.' }
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:id, :client_id, :client_customer_id, :password, :use_2fa, :country_code, :user_2fa_id, :user_email_code, :created, :updated, :deleted, :first_name, :last_name, :phone, :email)
    end
end

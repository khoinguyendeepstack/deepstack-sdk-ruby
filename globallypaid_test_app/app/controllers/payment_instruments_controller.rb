class PaymentInstrumentsController < ApplicationController
  before_action :set_payment_instrument, only: [:show, :edit, :update, :destroy]

  # GET /payment_instruments
  # GET /payment_instruments.json
  def index
    @payment_instruments = PaymentInstrument.all
  end

  # GET /payment_instruments/1
  # GET /payment_instruments/1.json
  def show
  end

  # GET /payment_instruments/new
  def new
    @payment_instrument = PaymentInstrument.new
  end

  # GET /payment_instruments/1/edit
  def edit
  end

  # POST /payment_instruments
  # POST /payment_instruments.json
  def create
    @payment_instrument = PaymentInstrument.new(payment_instrument_params)

    respond_to do |format|
      if @payment_instrument.save
        format.html { redirect_to @payment_instrument, notice: 'Payment instrument was successfully created.' }
        format.json { render :show, status: :created, location: @payment_instrument }
      else
        format.html { render :new }
        format.json { render json: @payment_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_instruments/1
  # PATCH/PUT /payment_instruments/1.json
  def update
    respond_to do |format|
      if @payment_instrument.update(payment_instrument_params)
        format.html { redirect_to @payment_instrument, notice: 'Payment instrument was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_instrument }
      else
        format.html { render :edit }
        format.json { render json: @payment_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_instruments/1
  # DELETE /payment_instruments/1.json
  def destroy
    @payment_instrument.destroy
    respond_to do |format|
      format.html { redirect_to payment_instruments_url, notice: 'Payment instrument was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_instrument
      @payment_instrument = PaymentInstrument.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_instrument_params
      params.require(:payment_instrument).permit(:type, :client_id, :customer_id, :billing_contact)
    end
end

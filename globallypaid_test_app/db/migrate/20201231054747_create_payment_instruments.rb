class CreatePaymentInstruments < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_instruments do |t|
      t.integer :type
      t.string :client_id
      t.string :customer_id
      t.integer :billing_contact

      t.timestamps
    end
  end
end

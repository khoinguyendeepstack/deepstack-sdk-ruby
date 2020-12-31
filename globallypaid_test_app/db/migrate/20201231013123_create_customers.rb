class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      # t.string :id
      t.string :client_id
      t.string :client_customer_id
      t.string :password
      t.boolean :use_2fa
      t.string :country_code
      t.string :user_2fa_id
      t.integer :user_email_code
      t.date :created
      t.date :updated
      t.date :deleted
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end

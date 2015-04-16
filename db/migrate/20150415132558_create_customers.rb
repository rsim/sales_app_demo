class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :full_name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state_province
      t.string :postal_code
      t.string :country
      t.date :birth_date
      t.string :gender, limit: 10
      t.timestamps
    end
  end
end

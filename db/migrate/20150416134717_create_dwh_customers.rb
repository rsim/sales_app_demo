class CreateDwhCustomers < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up { execute "CREATE SCHEMA dwh" }
      dir.down { execute "DROP SCHEMA dwh" }
    end

    create_table "dwh.d_customers" do |t|
      t.string :country
      t.string :state_province
      t.string :city
      t.string :full_name
      t.date :birth_date
      t.string :gender, limit: 10
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        add_index "dwh.d_customers", [:country, :state_province, :city, :full_name],
          name: "i_customers_country_state_city_full_name"
      end
    end
  end
end

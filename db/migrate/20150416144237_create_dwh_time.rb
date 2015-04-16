class CreateDwhTime < ActiveRecord::Migration
  def change
    create_table "dwh.d_time" do |t|
      t.date :date_value, unique: true
      t.integer :year
      t.integer :quarter
      t.integer :month
      t.integer :day
      t.string :year_name
      t.string :quarter_name
      t.string :month_name
      t.string :day_name
    end

    add_index "dwh.d_time", [:year, :quarter, :month, :day]
  end
end

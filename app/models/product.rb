class Product < ActiveRecord::Base
  belongs_to :product_class
  has_many :order_items
end

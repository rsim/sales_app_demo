module Dwh

  def self.load_dimensions!
    CustomerDimension.load!
    ProductDimension.load!
    TimeDimension.load!
  end

  def self.load_facts!
    SalesFact.load!
  end
end

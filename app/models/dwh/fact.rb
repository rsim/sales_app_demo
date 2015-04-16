class Dwh::Fact < ActiveRecord::Base
  self.abstract_class = true

  def self.table_name_prefix
    'dwh.f_'
  end

  def self.undecorated_table_name(class_name = base_class.name)
    table_name = class_name.to_s.demodulize.underscore
    table_name = table_name.sub('_fact', '')
    pluralize_table_names ? table_name.pluralize : table_name
  end

  def self.truncate!
    connection.execute "TRUNCATE TABLE #{table_name}"
  end

end

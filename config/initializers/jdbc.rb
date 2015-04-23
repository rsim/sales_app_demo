if defined?(JRUBY_VERSION)

  require 'jdbc/postgres'
  Jdbc::Postgres.load_driver

end

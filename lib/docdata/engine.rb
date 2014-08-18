module Docdata
  #
  # Simpel extend on the +Rails::Engine+ to add support for a new config section within
  # the environment configs
  #
  # @example default
  #   # /config/environments/development.rb
  # config.docata.username  = "myapp_com"
  # config.docata.password  = "pa55w0rd"
  # config.docata.test_mode = true
  #
  class Engine < Rails::Engine
    config.docdata = Docdata::Config
  end
end
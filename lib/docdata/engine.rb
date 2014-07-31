module Docdata
  #
  # Simpel extend on the +Rails::Engine+ to add support for a new config section within
  # the environment configs
  #
  # @example default
  #   # /config/environments/development.rb
  #   config.ideal_mollie.partner_id = 123456
  #
  class Engine < Rails::Engine
    config.docdata = Docdata
  end
end
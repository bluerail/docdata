# Docdata

Docdata is a Ruby binder for Docdata payments. Current status: in progress, not stable.

## Installation

Add this line to your application's Gemfile:

    gem 'docdata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docdata

## Lay of the land

Each transaction consists of 2 parts:

- Shopper (details about the shopper: name, email, etc.)
- Payment (details about the payment: currency, gross amount, etc.) 

## Example in Rails application

		# orders_controller.rb
		def start_transaction
			# find the order from your database
			@order = Order.find(params[:id])
		end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Docdata

Docdata is a Ruby binder for Docdata Payments. Current status: **in progress, not stable**. 

This gem relies on the awesom Savon gem to communicate with Docdata Payments' SOAP API.

## Installation

Add this line to your application's Gemfile:

    gem 'docdata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docdata

## Lay of the land

Each transaction consists of 2 - optionally 3 - parts:

- Shopper (details about the shopper: name, email, etc.)
- Payment (details about the payment: currency, gross amount, etc.) 
- LineItem (optionally list the products of this payment)


## Workflow
The general workflow is as follows:

1. Setup a `Docdata::Payment` object with the details of your order: `@payment = Docdata::Payment.new`
2. Call the `create` method (`@payment.create`)
3. On success, store the payment key and use `@payment.redirect_url` to redirect the consumer to the transaction page.

## Parameters
All the payment details that Docdata Payments requires, are - obviously - also required to make payments via this gem.

#### Docdata::Shopper:
| Name | Type | Required | Defaults to |
|-----------|------------|---------|----|
| id | String (ID for own reference) | Yes | |
| first_name | String | Yes | First Name |
|	last_name | String | Yes | Last Name |
| street | String | Yes | Main Street |
| house_number | String | Yes | 123 |
| postal_code | String | Yes | 2244 |
| city | String | Yes | City |
| country_code | String (ISO country code) | Yes | NL |
| language_code | String (ISO language code) | Yes | nl |
| email | String | Yes | random@example.com |

#### Docdata::Payment:
| Name | Type | Required |
|-----------|------------|---------|
| amount | Integer (amount in cents) | Yes |
| currency | String (ISO currency code) | Yes |
| order_reference | String (your own unique reference) | Yes |
| profile | String (name of your Docdata Payment profile)| Yes |
| shopper | Docdata::Shopper | Yes |
| line_items | Array (of Docdata::LineItem objects) | No |
| bank_id | String | No |
| prefered_payment_method | String | No |
| key | String (is availabel after successful 'create' action) | No (readonly)

#### Docdata::LineItem (optional):
| Name | Type | Required |
|-----------|------------|---------|
| name | String | Yes |
| quantity | Integer | Yes |
| unit_of_measure | String ('Books', 'Tickets') | Yes |
| description | String | Yes |
| image | String (URI to image) | No |
| price_per_unit | Integer (price in cents) | Yes |

## Default values
A quick warning about the default values for the Shopper object: **For some payment methods, Docdata Payments needs the actual information in order for the payment to take place.**

If you use `GIROPAY`, `SEPA` and `AFTERPAY` this is the case. (Maybe also in other payment methods, please let me know!)

## Example usage in Rails application
The example below assumes you have your application set up with a Order model, which contains the information needed for this transaction (amount, name, etc.).
```ruby
# orders_controller.rb
def start_transaction
	# find the order from your database
	@order = Order.find(params[:id])
	
	# initialize a shopper, use details from your order
	shopper = Docdata::Shopper.new(first_name: @order.first_name, last_name: @order.last_name)

	# set up a payment
		amount: @order.total, 
		currency: @order.currency, 
		shopper: shopper,
		profile: "My Default Profile",
		order_reference: "order ##{@order.id}",
	
	# create the payment via the docdata api and collect the result
	result = @payment.create

	if result.success?
		# Set the transaction key for future reference
		@order.update_column :docdata_key, result.key
	else
		# TODO: Display the error and warn the user that something went wrong.
	end
end
```

## Ideal

For transactions in the Netherlands, iDeal is the most common option. To redirect a user directly to the bank page (skipping the Docdata web menu page), you can ask your user to choose a bank from any of the banks listed in the `Docdata::Ideal.banks` method.

In `Docdata::Payment` you can set `bank_id` to any value. If you do, the redirect URI will redirect your user directly to the bank page.

Example code:
```ruby
# orders_controller.rb
def ideal_checkout
	@order = Order.find(params[:order_id])
	@banks = Docdata::Ideal.banks
end

def start_ideal_transaction
	@order = Order.find(params[:order_id])

	# initialize a shopper, use details from your order
	shopper = Docdata::Shopper.new(first_name: @order.first_name, last_name: @order.last_name)

	# set up a payment
	@payment = Docdata::Payment.new(
		amount: @order.total, 
		currency: @order.currency, 
		shopper: shopper,
		profile: "My Default Profile",
		order_reference: "order ##{@order.id}",
		bank_id: params[:bank_id]
	)

	# create the payment via the docdata api and collect the result
	result = @payment.create

	if result.success?
		# Set the transaction key for future reference
		@order.update_column :docdata_key, result.key
		# redirect the user to the bank page
		redirect_to @payment.redirect_url
	else
		# TODO: Display the error and warn the user that something went wrong.
	end
end

```

```erb
# ideal_checkout.html.erb
<h2>Choose your bank</h2>
<%= form_tag start_ideal_transaction_path, method: :post, target: "_blank" do %>
  <%= select_tag "bank_id", options_from_collection_for_select(@banks, "id", "name") %>
	<%= hidden_field_tag :order_id, @order.id %>
  <%= submit_tag "Proceed to checkout" %>
<% end %>
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make changes, document them and add tests (rspec)
4. Run the entire test suite and make sure all tests pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

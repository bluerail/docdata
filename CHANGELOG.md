## v0.2.2
* Minor bugfixes (dependency issues)

## v0.2.1
* We now assume a podium giftcard payment to be paid when total_registered == total_captured

## v0.2.0
* We now assume a payment to be paid when total_registered == total_acquirer_approved

## v0.1.9
* Bug fixed where 'paid?' returned false if respons status had both 'paid' and 'canceled' node in response XML.

## v0.1.8
* You can now make refunds. See documentation.
* Updated README

## v0.1.7
* Bug fixed where the gem didn't handle docdata XML response with multiple 'payment' nodes well. The gem assumed that the nodes where in chronological order, but they aren't.

## v0.1.6
* Bug fixed where a description contained an illegal character (& in this case)

## v0.1.5
* Fixed a bug that occured when docdata reponded with multiple 'payment' nodes in the return object.

## v0.1.0
* truncated description down to 50 characters in create xml

## v0.0.9
* added configuration settings
* updated documentation

## v0.0.6

* minor bug fixes
* added default_pm option
* set key and Docdata::Payment object in status response object

## v0.0.2 - v0.0.5

Version 0.0.5 is used in production environmints and works.

* added method 'Payment.find'
* added method 'Payment.cancel'
* much better response messages

## v0.0.1

* initial release
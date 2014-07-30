require 'rubygems'
require 'savon'
# gem 'savon', '~> 2.0'

# require 'rubyntlm'

url = "https://test.docdatapayments.com/ps/services/paymentservice/1_1?wsdl"
# client = Savon.client(wsdl: url, strip_namespaces: false)
# client.namespaces = { "xmlns:_1" => "http://www.docdatapayments.com/services/paymentservice/1_1/" }

# client.call(:create)
xml = File.read("#{File.dirname(__FILE__)}/create.xml")
client = Savon.client(wsdl: url, namespace: "http://www.docdatapayments.com/services/paymentservice/1_1/")

response = client.call(:create, xml: xml.to_s)

# response = client.call(:create, create_request: "<![CDATA#{xml}]]>")
puts response
# response = client.call(:create) do |locals|
#     locals.message "Query" => {"Head" => {"UserId" => "my_username_here", "Password" => "my_password_here", "SchemaName" => "StandardXML1_2"}, "Body" => {"MLS" => "nwmls", "PropertyType" => "RESI", "BeginDate" => "2014-04-17T00:25:00", "EndDate" => "2014-04-22T00:25:00"}}
# end

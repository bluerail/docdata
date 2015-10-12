<pre>
	<?php
	
		$key = $_GET['key'];
		
		//$url = "https://secure.docdatapayments.com/ps/services/paymentservice/1_2?wsdl"; // live url 
		$url = "https://test.docdatapayments.com/ps/services/paymentservice/1_2?wsdl";
		
		$client = new SoapClient( $url );
		
		//var_dump($client->__getFunctions());
			
		$parameters = array();
		
		$parameters['version'] = "1.2";
		
		//	merchant
		//$parameters['merchant']['name'] = $_POST['merchantname'];
		//$parameters['merchant']['password'] = $_POST['merchantpassword'];
		$parameters['merchant']['name'] = 'phptest';
		$parameters['merchant']['password'] = 'xxx';
			
		$parameters['paymentOrderKey'] = $key;
		
		//	dorequest	
		echo "<h2>Status</h2>";
		
		$response = $client->status( $parameters );
			
		if( isset( $response->statusSuccess->success ) ) {
			print_r($response->statusSuccess->report);
		} else {
			print_r( $response->statusError );
		}
	?>
</pre>

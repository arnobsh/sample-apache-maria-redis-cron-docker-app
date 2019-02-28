<?php
try {
	//create redis instance
    $redis = new Redis();
	//connect with server and port
    $redis->connect('localhost', 6379);
	//set value
    $redis->set('website', 'www.arnobsaha.com');
	//get value
    $website = $redis->get('website');
	//print www.phpflow.com
	echo $website;
    
} catch (Exception $ex) {
    echo $ex->getMessage();
}
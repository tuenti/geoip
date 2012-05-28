--TEST--
Checking geoip_db_reload
--SKIPIF--
<?php if (!extension_loaded("geoip")) print "skip"; ?>
--POST--
--GET--
--FILE--
<?php

var_dump(geoip_db_reload());

?>
--EXPECT--
bool(true)

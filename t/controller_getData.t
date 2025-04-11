use strict;
use warnings;
use Test::More;


use Catalyst::Test 'WifiWebUI';
use WifiWebUI::Controller::getData;

ok( request('/getdata')->is_success, 'Request should succeed' );
done_testing();

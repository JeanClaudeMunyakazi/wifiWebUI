use strict;
use warnings;
use Test::More;


use Catalyst::Test 'WifiWebUI';
use WifiWebUI::Controller::checkSSIDAvailability;

ok( request('/checkssidavailability')->is_success, 'Request should succeed' );
done_testing();

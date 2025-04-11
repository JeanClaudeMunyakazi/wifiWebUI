use strict;
use warnings;
use Test::More;


use Catalyst::Test 'WifiWebUI';
use WifiWebUI::Controller::setNTP;

ok( request('/setwifi')->is_success, 'Request should succeed' );
done_testing();

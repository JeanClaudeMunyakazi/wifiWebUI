use strict;
use warnings;
use Test::More;


use Catalyst::Test 'WifiWebUI';
use WifiWebUI::Controller::setCustom;

ok( request('/setcustom')->is_success, 'Request should succeed' );
done_testing();

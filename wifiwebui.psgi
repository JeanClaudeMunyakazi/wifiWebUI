#!/usr/bin/env perl

use strict;
use warnings;

use lib '/opt/wifiWebUI/lib';
use WifiWebUI;
my $app = WifiWebUI->apply_default_middlewares(WifiWebUI->psgi_app);
$app;
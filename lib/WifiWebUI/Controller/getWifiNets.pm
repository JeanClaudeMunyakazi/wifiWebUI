package WifiWebUI::Controller::getWifiNets;
use utf8;
use open ':std', ':utf8';
binmode(STDOUT, ":utf8");
use Encode;
use Moose;
use namespace::autoclean;
use Catalyst qw/
    Authentication
	Request
    Cache
/;
use Sort::Naturally 'nsort';

use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }
 
__PACKAGE__->config(namespace => '');

=head1 NAME

WifiWebUI::Controller::getWifiNets - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub getWifiNets :Path('/getWifiNets') :Args(0) {
    my ($self, $c) = @_;

    $c->authenticate({}, 'admin');

	my @APIresponseMessages = ();
	my @APIresponseDebugMessages = ();

	$c->stash->{_API_name} = $c->config->{name};
	$c->stash->{_API_version} = $c->config->{version};
	$c->stash->{_API_endpoint} = '/getWifiNets';

	my @cmdsetStatusWifiUP = `ip link set wlan0 up`;
	my @cmdsetStatusEth0UP = `ip link set eth0 up`;

	my @cmd = `iwlist wlan0 scan | grep ESSID`;
	my @wifiScanResult = ();
	my $hiddenESSIDs = 0;

		for my $i (@cmd) {

			if ($i =~ m/\s*ESSID\:\"(.*|\s)\"/i) {
				my $ESSID = "";
				$ESSID = $1;

				if ($ESSID ne "") {
					next if $ESSID =~ m/\\x00/i;
					# eval, decode and encode the UTF-8 string to unescape the special characters like "🤡cla‘💩iPhone💀"
					my $octets = eval qq("$ESSID");
					my $characters = decode('UTF-8', $octets, Encode::FB_CROAK); # Perl can print the ESSID to STDOUT now: print $characters."\n"; => "🤡cla‘💩iPhone💀"
					my $result = encode('UTF-8',$characters); # Now it's encoded again an Perl will see jibberish on STDOUT, but JSON can read it and we can push to the array and later on to the stack and return it in a JSON response: print $result."\n"; => ð¤¡claâð©iPhoneð
					push @wifiScanResult, $result;
				}

				if ($ESSID eq "") {
					$hiddenESSIDs++;
				}
			}
		}

	my @filteredAvailableWifiNetworks = uniq(@wifiScanResult);
	my @filteredAndSortedAvailableWifiNetworks = nsort(@filteredAvailableWifiNetworks); # sort in a human readable way
	$c->stash->{availableWifiNetworks} = \@filteredAndSortedAvailableWifiNetworks;


	$c->stash->{hiddenESSIDs} = $hiddenESSIDs;
	$c->stash->{_API_response_status} = 200;
	$c->stash->{_API_response_message} = 'success';

	$c->forward($c->view('JSON'));
}


sub uniq {
	my %seen;
	grep !$seen{$_}++, @_;
}


# We use the error action to handle errors
sub error : Private {
	my ($self, $c, $code, $reason) = @_;
	$reason ||= 'Unknown Error';
	$code ||= 500;
	
	$c->res->status($code);
	# Error text is rendered as JSON as well
	$c->stash->{data} = { error => $reason };
}


sub end : ActionClass('RenderView') {}

=encoding utf8

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

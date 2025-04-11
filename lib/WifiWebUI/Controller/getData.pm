package WifiWebUI::Controller::getData;
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
use File::Flock;
use File::Slurp;
use Try::Tiny;

use Data::Dumper;


BEGIN { extends 'Catalyst::Controller'; }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
 
__PACKAGE__->config(namespace => '');

=head1 NAME

WifiWebUI::Controller::getData - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub getData :Path('/getData') :Args(0) {
    my ($self, $c) = @_;

    $c->authenticate({}, 'admin');

	my @APIresponseMessages = ();
	my @APIresponseDebugMessages = ();

	$c->stash->{_API_name} = $c->config->{name};
	$c->stash->{_API_version} = $c->config->{version};
	$c->stash->{_API_endpoint} = '/getData';

	my @cmdsetStatusWifiUP = `ip link set wlan0 up`;
	my @cmdsetStatusEth0UP = `ip link set eth0 up`;

	lock($c->config->{pathToConfigJSON});
    my $configFile = read_file($c->config->{pathToConfigJSON}, chomp => 1);
	unlock($c->config->{pathToConfigJSON});
	my $configJSON;
		try {
			$configJSON = JSON->new->decode($configFile);
			$c->stash->{config} = $configJSON;
		}
		catch {
			$c->stash->{config} = "$_\n";
		};


	my @cmd = `iwconfig wlan0`;

	for my $i (@cmd) {

		if ($i =~ /ESSID\:\"(.+)\"/i) {
				my $ESSID = "";
				$ESSID = $1;

				if ($ESSID ne "") {
					next if $ESSID =~ m/\\x00/i;
					# eval, decode and encode the UTF-8 string to unescape the special characters like "🤡cla‘💩iPhone💀"
					my $octets = eval qq("$ESSID");
					my $characters = decode('UTF-8', $octets, Encode::FB_CROAK); # Perl can print the ESSID to STDOUT now: print $characters."\n"; => "🤡cla‘💩iPhone💀"
					my $result = encode('UTF-8',$characters); # Now it's encoded again an Perl will see jibberish on STDOUT, but JSON can read it and we can push to the array and later on to the stack and return it in a JSON response: print $result."\n"; => ð¤¡clað©iPhoneð
					$c->stash->{status}->{network}->{wifi}->{ESSID} = $result;
				}
	
				if ($ESSID eq "") {
					$c->stash->{status}->{network}->{wifi}->{ESSID} = undef;
				}

		}
		if ($i =~ /frequency\:(.+ Ghz)/i) {
			my $frequency = $1;
			$c->stash->{status}->{network}->{wifi}->{frequency} = $frequency;

		}
		if ($i =~ /Signal level\=(.+ dBM)/i) {
			my $RSSI = $1;
			$c->stash->{status}->{network}->{wifi}->{RSSI} = $RSSI;
		}
	}


	my @cmd2 = `/sbin/iw wlan0 station dump`;
	my $connectedTime = 0;

	if ($#cmd2 > 0) {
		for my $i (@cmd2) {
			my $txBitrate = "";
			my $rxBitrate = "";
			if ($i =~ /tx bitrate\:\s?(.+)/i) {
				$c->stash->{status}->{network}->{wifi}->{txBitrate} = $1;

			}

			if ($i =~ /rx bitrate\:\s?(.+)/i) {
				$c->stash->{status}->{network}->{wifi}->{rxBitrate} = $1;

			}

			if ($i =~ /connected time\:\s?(.+) seconds/i) {

					if ($connectedTime => 1) {
						$connectedTime = $1;
						$c->stash->{status}->{network}->{wifi}->{connectionStatus} = "online";
						$c->stash->{status}->{network}->{wifi}->{connectedTime} = $connectedTime;
					}

					else {
						$c->stash->{status}->{network}->{wifi}->{connectionStatus} = "offline";
					}
			}

			if ($connectedTime == 0) {
				$c->stash->{status}->{network}->{wifi}->{connectionStatus} = "error";
				$c->stash->{status}->{network}->{wifi}->{connectedTime} = $connectedTime;
			}

		}
	}
	else {
		$c->stash->{status}->{network}->{wifi}->{connectionStatus} = "offline";
	}


	my $cmd = "ip addr show";
	my %interfaces;

	open my $pipe, '-|', $cmd or die "(E) could not execute: $cmd: $!\n";
	my $device;
		while ( my $line = <$pipe> ) {

			if ( $line =~ m/^\d+:\s+([^:]+): <([^>]+)>/ ) {
					$device = $1;
					$interfaces{$device}->{abilities} = $2;
					$interfaces{$device}->{name} = $device;
			}

			while ( $line =~ m/(mtu|state|qlen|brd|inet?) (\S+)/g ) {

				my $key = $1;
				my $val = $2;

				if ($key eq "inet") {
					$val =~ m/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/(\d{1,2})/;
					$interfaces{$device}->{ip} = $1;
					$interfaces{$device}->{netmask} = $2;
					next;
				}

				if (($val eq "ff:ff:ff:ff:ff:ff") || ($val eq "00:00:00:00:00:00")) {
					$val = undef;
				}

				$interfaces{$device}->{$1} = $val;
			}
		}
	close $pipe;
	$c->stash->{status}->{network}->{devices} = \%interfaces;


	my $cmd3 = "dhcp-lease-list";
	my %DHCPleases;

	open my $pipe, '-|', $cmd3 or die "Could not execute: $cmd3: $!\n";
	my $device;
		while ( my $line = <$pipe> ) {
			if ( $line =~ m/(\S+|\:)\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/ ) {
					$DHCPleases{$2}->{mac} = $1;
					$DHCPleases{$2}->{ip} = $2;
					$DHCPleases{$2}->{hostname} = $3;
					$DHCPleases{$2}->{validUntilDate} = $4;
					$DHCPleases{$2}->{validUntilTime} = $5;
					$DHCPleases{$2}->{manufacturer} = $6;
			}
		}
	close $pipe;
	$c->stash->{status}->{network}->{DHCP}->{leases} = \%DHCPleases;

	if ($c->stash->{status}->{network}->{wifi}->{connectionStatus} eq "online") {

		my @DNStestServers = ('google.com', 'amazon.com', 'example.com');
		my $DNStestCommand = "ping -c 2 -I wlan0";
		my %pingResults;

		for my $testServer (@DNStestServers) {
			my $cmd = $DNStestCommand." ".$testServer;
			open my $pipe, '-|', $cmd or die "Could not execute: $cmd $!\n";
				while ( my $line = <$pipe> ) {
						if ( $line =~ m/(\d{1,}) .* (\d{1,}) .* (\d{1,})\% .* (\d{1,})/ ) {
						#if ( $line =~ m/(Network is unreachable)|(Temporary failure in name resolution)|.* (.*) \((.*)\)\: icmp\_seq\=(\d{1,}) ttl\=\d{1,} time\=(.*)$/ ) {
							$pingResults{$testServer}->{packetsTX} = $1;
							$pingResults{$testServer}->{packetsRX} = $2;
							$pingResults{$testServer}->{packetLoss} = $3;
							$pingResults{$testServer}->{wcTime} = $4;

					}
				}
			close $pipe;
		}
		$c->stash->{status}->{network}->{DNS}->{status} = \%pingResults;
	}

	$c->stash->{_API_response_status} = 200;
	$c->stash->{_API_response_message} = 'success';

	$c->forward($c->view('JSON'));
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

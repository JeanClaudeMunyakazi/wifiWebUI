package WifiWebUI::Controller::Root;
use utf8;
#use open ':std', ':utf8';
use Moose;
use namespace::autoclean;
use Catalyst qw/
    Authentication
	Request
    Cache
/;
use JSON::Parse 'json_file_to_perl';
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

WifiWebUI::Controller::Root - Root Controller for WifiWebUI

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut


sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	my @cmdsetStatusWifiUP = `ip link set wlan0 up`;
	my @cmdsetStatusEth0UP = `ip link set eth0 up`;

    # setup 1:1 NAT router
    system($c->config->{routerScript});

    $c->authenticate({}, 'admin');

    my $p = json_file_to_perl($c->config->{pathToConfigJSON});
    
    $c->stash->{baseURL} = $c->request->base;
    $c->stash->{color} = $p->{custom}{color};
    $c->stash->{companyName} = $p->{custom}{companyName};
    $c->stash->{deviceName} = $p->{custom}{deviceName};
    $c->stash->{logo} = $p->{custom}{logo};

    $c->stash->{version} = $c->config->{version};
    $c->stash->{template} = $c->config->{pathToWEBtemplate};
    $c->forward( $c->view('WEB') );
}


=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'WifiWebUI API - 404 Error: resource not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

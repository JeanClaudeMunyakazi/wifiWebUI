package WifiWebUI::Controller::setCustom;
use Moose;
use namespace::autoclean;
use File::Slurp;
use JSON;
use Catalyst qw/
    Authentication
    Request
    Cache
/;
BEGIN { extends 'Catalyst::Controller'; }
=head1 NAME

WifiWebUI::Controller::setCustom - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub setCustom :POST :Path('/setCustom') :Args(0) :Consume('application/json') {
    my ($self, $c) = @_;
    my $data = $c->req->body_data;
    
    $c->authenticate({}, 'admin');
    
    my $configFile = read_file($c->config->{pathToConfigJSON}, chomp => 1);
	my $configJSON = JSON->new->utf8->decode($configFile);

    $configJSON->{custom}->{color} = $data->{color};
    $configJSON->{custom}->{deviceName} = $data->{deviceName};

    my $jsonPretty = to_json($configJSON, {utf8 => 1, pretty => 1});

    open (my $fhJSON, ">", $c->config->{pathToConfigJSON}) || die "$!\n";
        print $fhJSON $jsonPretty;
    close $fhJSON || die($!);

    $c->stash->{config} = $configJSON->{custom};
    $c->stash->{_API_name} = $c->config->{name};
    $c->stash->{_API_version} = $c->config->{version};
    $c->stash->{_API_endpoint} = '/setCustom';
    $c->stash->{_API_response_status} = 200;
    $c->stash->{_API_response_message} = 'success';
    $c->forward($c->view('JSON'));
}



=encoding utf8

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

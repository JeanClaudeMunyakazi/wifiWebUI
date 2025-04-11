package WifiWebUI::Controller::setReboot;
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

WifiWebUI::Controller::setReboot - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub setReboot :POST :Path('/setReboot') :Args(0) :Consume('application/json') {
    my ($self, $c) = @_;
    my $data = $c->req->body_data;

    $c->authenticate({}, 'admin');

    $c->stash->{_API_name} = $c->config->{name};
    $c->stash->{_API_version} = $c->config->{version};
    $c->stash->{_API_endpoint} = '/setReboot';
    $c->stash->{_API_response_status} = 200;
    $c->stash->{_API_response_message} = 'success';
    $c->forward($c->view('JSON'));

    `reboot`;
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

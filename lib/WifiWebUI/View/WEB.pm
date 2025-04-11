package WifiWebUI::View::WEB;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';


__PACKAGE__->config(
    # any TT configuration items go here
    TEMPLATE_EXTENSION => '.tt',
    CATALYST_VAR => 'c',
    TIMER        => 0,
    ENCODING     => 'utf-8',
    # Not set by default
    PRE_PROCESS        => 'config/main',
    WRAPPER            => 'site/wrapper',
    render_die => 1, # Default for new apps, see render method docs
    # expose_methods => [qw/method_in_view_class/]
);

=head1 NAME

WifiWebUI::View::WEB - TT View for WifiWebUI

=head1 DESCRIPTION

TT View for WifiWebUI.

=head1 SEE ALSO

L<WifiWebUI>

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

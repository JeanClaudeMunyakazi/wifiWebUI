package WifiWebUI::View::JSON;

use strict;
use utf8;
use open ':std', ':utf8';
use namespace::autoclean;
use base 'Catalyst::View::JSON';
use JSON::PP ();

WifiWebUI->config(encoding=>undef);

sub encode_json {
	my($self, $c, @data) = @_;
	my $json = $data[0];
	# sort and pretty print
	#my $encoder=JSON::PP->new()->pretty->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode(\@data);
	# just sort
	my $encoder = JSON::PP->new->pretty()->sort_by(sub { $JSON::PP::a cmp $JSON::PP::b })->encode($json);
	# minified
	#my $encoder=JSON::PP->new()->encode(\@data);
}

=head1 NAME

WifiWebUI::View::JSON - Catalyst View

=head1 DESCRIPTION

Catalyst View.


=encoding utf8

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );


1;

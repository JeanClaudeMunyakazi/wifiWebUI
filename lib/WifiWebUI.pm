package WifiWebUI;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
	Authentication
	Authorization::Roles
    Cache
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in wifiwebui.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'WifiWebUI',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
        'View::WEB' => {
            INCLUDE_PATH => [
                __PACKAGE__->path_to( 'root', 'src' ),
                __PACKAGE__->path_to( 'root', 'lib' ),
            ],
        },
        'Plugin::Static::Simple' => {
                mime_types => {
                mf => 'text/cache-manifest',
            },
        },
        #require_ssl => {
        #    remain_in_ssl => 0,
        #    no_cache => 0,
        #    detach_on_redirect => 1,
        #},
);

__PACKAGE__->config(
	'Plugin::Authentication' => {
		admin => {
			credential => {
				class => 'HTTP',
				password_field => 'password',
				password_type => 'clear'
			},
			store => {
				class => 'Minimal',
				users => {
					admin => { password => "hammer4296"  }
				}
			}
		}
	}
);

# typical example for Cache::Memcached::libmemcached
__PACKAGE__->config->{'Plugin::Cache'} {backend} = {
	class   => "Cache::Memcached::libmemcached",
	servers => ['127.0.0.1:11211'],
	debug   => 2,
};


# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

WifiWebUI - Catalyst based application

=head1 SYNOPSIS

    script/wifiwebui_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

=head1 AUTHOR

cla

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

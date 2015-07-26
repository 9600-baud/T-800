#!/usr/bin/env perl
package T800;

use Moose;
use T800::Config;
use Moose::Autobox;
use FindBin qw($Bin);

use Module::Runtime qw(require_module);

with 'Universa::Role::Configuration' => {
    confdir    => "$Bin/etc",
    configfile => 't-800.yml',
    class      => 'T800::Config',
};

with 'Universa::Role::PluginManagement' => {
    autoloader       => '_build_plugins',
    role_restriction => 'T800::Role::Plugin',
    with_prefix      => 'T800::Role',
};

extends 'Reflex::Base';
use Reflex::POE::Session;
use Reflex::Trait::Watched qw(watches);

use POE qw(Component::IRC);

has 'irc'    => (
    isa      => 'Object|Undef',
    is       => 'rw',
    builder  => '_build_irc_component',
    );

watches 'poco_watcher' => (
    isa     => 'Reflex::POE::Session',
    role    => 'poco', 
    );

sub _build_irc_component {
    my $self = shift;
    
    POE::Component::IRC->spawn(
	nick     => $self->config->nick,
	ircnmame => $self->config->ircname,
	server   => $self->config->host,
	Password => $self->config->password,
	UseSSL   => $self->config->ssl,
	Port     => $self->config->port,
	);
}

sub BUILD {
    my $self = shift;

    use Data::Dumper;
    #print Dumper $self->config;
    
    $self->poco_watcher(
	Reflex::POE::Session->new(
	    sid => $self->irc->session_id));

    $self->run_within_session(
	sub {
	    $self->irc->yield( register => 'all' );
	    $self->irc->yield( connect  => {}    );
	    print "connecting...\n";
	}
	);
}

sub on_poco_irc_001 {
    my $self = shift;

    print "Connected.\n";

    foreach my $channel ( @{ $self->config->{'channels'} } ) {
	$self->irc->yield( join => $channel );
	print "Joining channel: $channel\n";
    }
}

sub on_poco_irc_public {
    my ($self, $event) = @_;

    print "irc_public\n";
    
    $self->plugin_dispatch(
	'PublicReceiver' => 'on_irc_public',
	@{ $event->args }[0, 1, 2]);
}

sub on_poco__default {
    my ($self, $event) = @_;

    use Data::Dumper;
    print Dumper @_;
}

# This snippet is from Universa:
# override for load_plugin to pass core instance to constructor:
# TODO: Fix PluginManagement so that it will accept arguments to plugins
sub _load_plugin {
    my ($self, $plugin_name) = @_;
    # We ignore orig here, because we are replacing it.
    
    require_module($plugin_name);
    my $plugin_obj = $plugin_name->new( core => $self );
    $plugin_obj;
}

# Snippet from Universa:
sub _build_plugins {
    my $self = shift;
    my @autoloaded = ();
    
    if (exists ($self->config->{'plugins'})) {
	print "loading plugins...\n";
	my $plugins = $self->config->{'plugins'};
	
        foreach my $plugin ($self->config->{'plugins'}->flatten) {
	    
            print "Loading plugin: '$plugin'\n";
            my $plugin = $self->_load_plugin($plugin);
	    push @autoloaded, $plugin;
        }
    }

    else {
	print "No plugins will be loaded\n";
    }

    \@autoloaded;
}

sub run {
    my $self = shift;

    $self->_plugins; # initialize plugins

    my @init_levels = qw(
        t800_preinit
        t800_init
        t800_postinit
    );

    $self->plugin_dispatch( 'Initialization' => $_ ) foreach (@init_levels);
    $self->run_all;
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__->new->run unless caller;

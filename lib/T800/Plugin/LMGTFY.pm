package T800::Plugin::LMGTFY;

use Moose;
use URI::Escape::XS qw(uri_escape);

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';

sub BUILD {
    my $self = shift; 
    $self->name('lmgtfy');
    $self->add_command('_default' => 'lmgtfy');
}

sub lmgtfy {
    my ($self, $who, $where, $what) = @_;
    my ($nick, $params) = split ' ', $what, 2;
	
	my $channel = $where->[0];
	my $message = "$nick: https://google.com/search?q=" . uri_escape($params) ;

	$self->irc->yield(privmsg => $channel => $message);

}

__PACKAGE__->meta->make_immutable;


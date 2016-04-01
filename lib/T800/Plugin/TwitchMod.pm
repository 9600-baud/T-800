package T800::Plugin::TwitchMod;

use Moose;
use Data::Dumper;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';


sub BUILD { shift->name('twitchmod') }

sub on_privmsg {
    my ($self, $who, $where, $what) = @_;
    return unless $what;
    my $channel = $where->[0];
    my $message = '';
    my ($cmd, $params) = split ' ', $what, 2;
   
    if ($cmd eq $self->core->config->trigger . 'timeout') {

        my $length = (split ' ', $params)[0] * 60;
	my $user = (split ' ', $params)[1];

	my $message = ".timeout $user $length";
	$self->irc->yield(privmsg => $channel => $message);
    }
    if ($cmd eq $self->core->config->trigger . 'purge'){
        my $user = (split ' ', $params)[0];
	my $message = ".timeout $user 1";
	$self->irc->yield(privmsg => $channel => $message);
    }

}
__PACKAGE__->meta->make_immutable;


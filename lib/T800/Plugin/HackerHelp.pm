package T800::Plugin::HackerHelp;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';

sub BUILD {
	my $self = shift;

	$self->name('hackerhelp');
}

sub on_privmsg {
	my ($self, $who, $where, $what ) = @_;
	my ($nick, $channel) = ((split '!', $who)[0],$where->[0]);
    print $channel;
    $channel = $nick unless $channel =~ m/^#/;
    return unless $channel eq "#mainehackerclub";
    if ($what =~ m/^help$/iu) {
        $self->irc->yield('privmsg', $channel, "I do apologize, but we need more information than just the word 'help'. We are a group of technology enthusiasts. We do not condone any illegal activities, such as 'cracking' and 'exploiting' systems. If you wish to learn about what we do, you can visit http://www.hackmaine.org/");
    }
}
__PACKAGE__->meta->make_immutable;

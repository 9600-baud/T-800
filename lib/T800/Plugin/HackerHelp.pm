package T800::Plugin::HackerHelp;

use Moose;
use POE qw(Kernel Session);

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';

has 'timeout' => ( is => 'rw', isa => 'Int', default => 1 );

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
        return unless $self->timeout;
        $self->irc->yield('privmsg', $channel, "I do apologize, but we need more information than just the word 'help'. We are a group of technology enthusiasts. We do not condone any illegal activities, such as 'cracking' and 'exploiting' systems. If you wish to learn about what we do, you can visit http://www.hackmaine.org/");
        $self->timeout(0);
        POE::Session->create(
            inline_states => {
                _start => sub {
                    $_[KERNEL]->alarm( resetto => time() + 300, 0 );
                },
                resetto => sub {
                    $self->timeout(1);
                },
            }
        );
    }
}
__PACKAGE__->meta->make_immutable;

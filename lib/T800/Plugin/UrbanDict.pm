package T800::Plugin::UrbanDict;

use Moose;
use WebService::UrbanDictionary;

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';


sub BUILD { shift->name('urbandict') }

sub on_privmsg {
    my ($self, $who, $where, $what) = @_;
    return unless $what;

    my ($cmd, $params) = split ' ', $what, 2;
    if ($cmd eq $self->core->config->trigger . 'urbandict') {
        my $ud = WebService::UrbanDictionary->new;
	my $results = $ud->request($params);
	my $defs = shift @{$results->definitions};
        my $def = undef;
	if (defined $defs) {	
        $def = $defs->definition;
	} else {
	$def = "This has not been defined.";
	}
        my $channel = $where->[0];
	
	print $params . "\n";
	my $message = "Definition of $params: $def"; 

	$self->irc->yield(privmsg => $channel => $message);
    }
}

__PACKAGE__->meta->make_immutable;


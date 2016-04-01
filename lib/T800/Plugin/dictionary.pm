package T800::Plugin::dictionary;

use Moose;
use WebService::MerriamWebster;

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';


sub BUILD {
    my $self = shift; 
    $self->name('define');
    $self->add_command('_default' => 'dictionary');
}

sub dictionary {
    my ($self, $who, $where, $what) = @_;
    my $nick = (split '!', $who)[0];
    my $mw = WebService::MerriamWebster->new(dict => "collegiate", word => $what, key => "0a0d6b4e-6996-4e90-9898-eaa8673c4b0b");
    print $what;
    my @definition = $mw->entries();
    binmode(STDOUT, ":utf8");
    print $definition[0];
    my $splitter = (split '<dt>', $definition[0])[1];
    my $def = (split '</dt>', $splitter)[0];
    $def =~ s/\<.*\>//;
	print $def;
	my $channel = $where->[0];
	my $message = "$nick: $def" ;

	$self->irc->yield(privmsg => $channel => $message);
}

__PACKAGE__->meta->make_immutable;


package T800::Plugin::TwitchCap;

use Moose;

with 'T800::Role::Plugin';
with 'T800::Role::IRCHandler';
with 'T800::Role::Initialization';
with 'T800::Role::SpecialMessages';

sub BUILD {
    my $self = shift;

    $self->name('twitchcap');
}

sub on_001 {
    my $self = shift;
    $self->irc->yield( cap => "REQ :twitch.tv/membership" );
    $self->irc->yield( cap => "REQ :twitch.tv/tags" );
    $self->irc->yield( cap => "REQ :twitch.tv/commands" );

}

__PACKAGE__->meta->make_immutable;


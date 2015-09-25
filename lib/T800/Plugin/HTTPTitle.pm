package T800::Plugin::HTTPTitle;

use Moose;
use Data::Validate::URI qw(is_web_uri);
use Mojo::UserAgent;
use Text::Trim qw(trim);

with 'T800::Role::Plugin';
with 'T800::Role::MessageReceiver';
with 'T800::Role::Initialization';
with 'T800::Role::IRCHandler';

sub BUILD {
	my $self = shift;

	$self->name('httptitle');
}

sub on_privmsg {
	my ($self, $who, $where, $what ) = @_;
	my ($nick, $channel) = ((split '!', $who)[0],$where->[0]);
        print $channel;
        $channel = $nick unless $channel =~ m/^#/;
	my $ua = Mojo::UserAgent->new;
	my @message = (split / /, $what);
	my $urlcount = 0;
	return unless $channel ne "#mainehackerclub";
	foreach (@message) {
		if (is_web_uri($_)) {   
                        $urlcount++;
			my $title = "";
			$title = $ua->max_redirects(3)->get($_)->res->dom->at('title')->text if defined $ua->max_redirects(3)->get($_)->res->dom->at('title');
                        
                        if (defined $title and $title ne '') {
			trim $title;
                        my $temp = 0;
			foreach ((split/\n/,$title)){
                                $self->irc->yield(
					'privmsg',
					$channel,
					"$_"
				);
				$temp++;
				last if $temp == 3; 
			}
			last if $urlcount > 4;
		}
	}}
}

__PACKAGE__->meta->make_immutable;

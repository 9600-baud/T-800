package T800::Plugin::Karma;

use Moose;
use DBI;
use DBD::SQLite;

with 'T800::Role::Plugin';
with 'T800::Role::PluginCommands';
with 'T800::Role::MessageReceiver';
with 'T800::Role::IRCHandler';

sub BUILD {
    my $self = shift;
    $self->name('karma');

    $self->add_command(
        '_default' => 'listkarma',
        );

    my $dbh = DBI->connect("dbi:SQLite:dbname=etc/karma.db","","", {RaiseError => 1}) or die $DBI::errstr;
    my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS karma(ID INT PRIMARY KEY NOT NULL, item TEXT NOT NULL, karma INT NOT NULL, lastchange INT NOT NULL);");
    $sth->execute();
    $sth->finish();
    $dbh->disconnect();
}

sub listkarma {
    my ($self, $who, $where, $what) = @_;
    my $channel = $where->[0];
    my $item = $what->[3];

    my $dbh = DBI->connect("dbi:SQLite:dbname=etc/karma.db","","", {RaiseError => 1}) or die $DBI::errstr;
    my $sth = $dbh->prepare("SELECT * FROM karma WHERE item = $item;");
    $sth->execute();
    my $result = $sth->fetch();
    use Data::Dumper;
    print Dumper $result;
    $sth->finish();   
    $dbh->disconnect(); 
}

sub on_privmsg {
    #TODO Karma++
    #TODO Karma--
    #TODO reset_karma
}

package Bot::Phenwick;
use 5.12.0;
use Moses;
use namespace::autoclean;

# ABSTRACT: Phenny in Perl

server 'irc.perl.org';
nickname 'phenwick';
channels '#phenwick'; #'#axkit-dahut';

plugins
  DuckDuckGo => 'Bot::Phenwick::Plugin::DuckDuckGo',
  Tell       => 'Bot::Phenwick::Plugin::Tell',
  Time       => 'Bot::Phenwick::Plugin::Time',
  Unicode    => 'Bot::Phenwick::Plugin::Unicode',
  Weather    => 'Bot::Phenwick::Plugin::Weather',
  Wikipedia  => 'Bot::Phenwick::Plugin::Wikipedia',
  ;

event irc_bot_addressed => sub {
    my ( $self, $nickstr, $channel, $msg ) = @_[ OBJECT, ARG0, ARG1, ARG2 ];
    my ($nick) = split /!/, $nickstr;
    given ($msg) {
        when (/^\?$/) {
            $self->privmsg( $channel => "$nick: ?" );
        }
    }
};

1;
__END__


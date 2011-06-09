package Bot::Phenwick::Plugin::DuckDuckGo;
use 5.12.0;
our $VERSION = '0.01';
use Moses::Plugin;
use DateTime;
use WWW::DuckDuckGo;

has ddg => (
    isa     => 'WWW::DuckDuckGo',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_ddg',
    handles => { search => 'zci', },
);

sub _build_ddg {
    WWW::DuckDuckGo->new( http_agent_name => __PACKAGE__ . '/' . $VERSION );
}

#
# Blatantly Stolen from RoboDuck (Getty++)
#

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ($$message) {
        when (/^\.ddg\s*(.*)?$/) {
            my $res = $self->search($1);
            given ($res) {
                when ( $_->has_answer ) {
                    my $reply = "${\$res->answer} (${\$res->answer_type})";
                    $self->privmsg( $_ => $reply ) for @$$channels;
                }
                when ( $_->has_defintion ) {
                    my $reply = $res->definiton;
                    $self->privmsg( $_ => $reply ) for @$$channels;
                }
                when ( $_->has_abstract_text ) {
                    my $reply = $res->abstract_text;
                    $self->privmsg( $_ => $reply ) for @$$channels;
                }
                when ( $_->has_heading ) {
                    my $reply = $res->heading;
                    $self->privmsg( $_ => $reply ) for @$$channels;
                }

                default {
                    my $reply = "No clue.";
                    $self->privmsg( $_ => $reply ) for @$$channels;
                }
            }
            return PCI_EAT_ALL;
        }
        default { return PCI_EAT_NONE; };
    }
}

1;
__END__

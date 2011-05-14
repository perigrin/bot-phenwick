package Bot::Phenwick::Plugin::Time;
use 5.12.0;
use Moses::Plugin;
use DateTime;

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ($$message) {
        when (/^\.t\s*([\w\/]+)?$/) {
            my $tz = ( $1 // 'EST5EDT' );
            my $dt = DateTime->now( time_zone => $tz )->strftime('%c %Z (%z)');
            $self->privmsg( $_ => $dt ) for @{$$channels};
            return PCI_EAT_ALL;
        }
        default { return PCI_EAT_NONE; };
    }
}

1;
__END__

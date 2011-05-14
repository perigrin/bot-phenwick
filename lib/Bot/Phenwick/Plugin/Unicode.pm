package Bot::Phenwick::Plugin::Unicode;
use 5.14.0;
use Moses::Plugin;
use Unicode::UCD qw(charinfo);
use Encode 'decode_utf8';

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ( decode_utf8($$message) ) {
        when (/^\.u\s+(\X+)$/) {
            my $info  = charinfo( ord $1 );
            my $reply = "$info->{name} (U+$info->{code})";
            $self->privmsg( $_ => $reply ) for @{$$channels};
            return PCI_EAT_ALL;
        }
        default { return PCI_EAT_NONE };
    }
}

1;
__END__

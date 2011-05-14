package Bot::Phenwick::Plugin::Weather;
use 5.14.0;
use Moses::Plugin;
use Geo::ICAO qw(code2airport);
use Weather::Google;

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ($$message) {
        when (/^\.weather\s*(\w{4})?$/) {
            my $icao = uc $1;
            my ( $airport, $location ) = code2airport($icao);
            my $gw   = Weather::Google->new($location);
            my $cur  = $gw->current;
            my $cond = do {
                given ( $cur->{condition} ) {
                    when (/^Cloudy/i) { "$_ \x{2601}" }
                    when (/^Sunny/i)  { "$_ \x{263C}" }
                    default         { $_ }
                }
            };
            my $f = "$cur->{temp_f}\x{2109}";
            my $c = "$cur->{temp_c}\x{2103}";
            my $reply = "$cond, $f ($c), $$cur{humidity}, $$cur{wind_condition} - $icao ($airport)";
            $self->privmsg( $_ => $reply ) for @{$$channels};
            return PCI_EAT_ALL;
        }
        default { return PCI_EAT_NONE; };
    }
}

1;
__END__

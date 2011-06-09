package Bot::Phenwick::Plugin::Wikipedia;
use 5.12.0;
use utf8::all;
use Moses::Plugin;
use WWW::Wikipedia;
use Text::Sentence qw( split_sentences );

has wikipedia => (
    isa     => 'WWW::Wikipedia',
    lazy    => 1,
    builder => '_build_wikipedia',
    handles => { search_wikipedia => 'search', },
);

sub _build_wikipedia { WWW::Wikipedia->new() }

sub parse_entry {
    my ( $self, $entry ) = @_;
    return "$1 not found." unless $entry;
    return join( ', ', "$1 not found, try:", $entry->related )
      unless $entry->text;

    my $text = $entry->text_basic;
    $text =~ s/\A\s*\{.*\}\s+$//ms;

    ($text) = split_sentences($text);
    ( my $src = $entry->{src} ) =~ s/&action=raw//;
    $text = "$text $src";
}

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ($$message) {
        when (/^\.wik\s*(.*)$/) {
            my $entry = $self->search_wikipedia($1);
            my $reply = $self->parse_entry($entry);
            $self->privmsg( $_ => $reply ) for @{$$channels};
            return PCI_EAT_ALL;
        }
        default { warn 'default'; return PCI_EAT_NONE; };
    }
}

1;
__END__

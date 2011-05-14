package Bot::Phenwick::Plugin::Unicode;
use 5.14.0;
use Moses::Plugin;
use Unicode::UCD qw(charinfo);
use Encode 'decode_utf8';
use Config;
use MooseX::Types::Path::Class qw(File);

use open ':std' => ':utf8';

has uni_file => (
    isa     => File,
    is      => 'ro',
    coerce  => 1,
    builder => '_build_uni_fh'
);

sub _build_uni_fh {
    for (@INC) {
        my $file = "$_/unicore/UnicodeData.txt";
        next unless -f -r $file;
        return $file;
    }
    confess 'Cannot find UnicodeData.txt in @INC';
}

#
# Stolen blatently from App::uni by Audrey who got it from Larry
#

sub unicode_grep {
    my ($self) = (shift);
    utf8::decode( my $regex = join( ' ', @_ ) );
    if ( length $regex == 1 ) {
        $regex = sprintf( '(?:%s|%04X)', $regex, ord $regex );
    }
    my $file    = $self->uni_file;
    my $replies = [];
    open my $fh, '<:mmap', $file or confess "Couldn't open $file: $!";
    for (<$fh>) {
        if ( /$regex/i and my ( $code, $name ) = /(\w+);([^;]+)/ ) {
            next unless [ $name, $code ] ~~ /$regex/i;
            my $line = chr( hex $code ) . " $name (U+$code)";
            push $replies, $line;
        }
    }
    close $fh;
    return $replies;
}

#
# Public Events
#

sub S_public {
    my ( $self, $irc, $nickstring, $channels, $message ) = @_;
    given ( decode_utf8($$message) ) {
        when (/^\.u\s+(\X+)$/) {
            my $info  = charinfo( ord $1 );
            my $reply = "$info->{name} (U+$info->{code})";
            $self->privmsg( $_ => $reply ) for @{$$channels};
            return PCI_EAT_ALL;
        }
        when (/^\.ug\s+(.+)$/) {
            my $replies = $self->unicode_grep($1);
            if ( @$replies > 4 ) {
                my $i     = scalar @$replies;
                my $reply = "Too many choices ($i), please be more specfic.";
                $self->privmsg( $_ => $reply ) for @{$$channels};
                return PCI_EAT_ALL;
            }
            for my $line (@$replies) {
                $self->privmsg( $_ => $line ) for @{$$channels};
            }
            return PCI_EAT_ALL;
        }
        when (/^\.uga\s+(.+)$/) {
            my $replies = $self->unicode_grep($1);
            for my $line (@$replies) {
                $self->privmsg( $_ => $line ) for @{$$channels};
            }
            return PCI_EAT_ALL;
        }
        default { return PCI_EAT_NONE };
    }
}

1;
__END__

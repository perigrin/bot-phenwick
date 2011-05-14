use 5.12.0;
{

    package Bot::Phenwick::Plugin::Tell::Message;
    use Moose;
    use namespace::autoclean;
    use DateTime;

    has [qw(from for message channel)] => (
        isa      => 'Str',
        is       => 'ro',
        required => 1
    );

    has timestamp => (
        isa     => 'DateTime',
        is      => 'ro',
        default => sub {
            DateTime->now();
        }
    );

    sub string {
        my $self = shift;
        my $time = $self->timestamp;
        return "${\$self->for}: $time <${\$self->from}> ${\$self->message}";
    }
}

{

    package Bot::Phenwick::Plugin::Tell;
    use Moses::Plugin;
    use namespace::autoclean;

    use Try::Tiny;
    use KiokuX::Model;
    use Regexp::Common qw(IRC);

    has model => (
        isa     => 'KiokuX::Model',
        is      => 'ro',
        builder => '_build_model',
        handles => [qw(search store delete new_scope)],
    );

    sub _build_model {
        KiokuX::Model->new(
            dsn        => "dbi:SQLite:tell.db",
            extra_args => {
                create  => 1,
                columns => [
                    for => {
                        data_type   => "varchar",
                        is_nullable => 0,
                    },
                ],
            }
        );
    }

    sub S_bot_addressed {
        my ( $self, $irc, $nickstring, $channels, $message ) = @_;
        given ($$message) {
            when (qr/^tell\s+$RE{IRC}{nick}{-keep}\s+(.*)$/) {
                my ($nick) = split /!/, $$nickstring;
                my $msg = Bot::Phenwick::Plugin::Tell::Message->new(
                    from    => $nick,
                    for     => $1,
                    message => $2,
                    channel => $$channels->[0],
                );
                my $scope = $self->new_scope;
                $self->store($msg);
                my $reply = "Okay $nick I will tell $1 that when I see them.";
                $self->privmsg( $_ => $reply ) for @$$channels;
                return PCI_EAT_ALL;
            }
            default { return PCI_EAT_NONE; };
        }
    }

    sub S_public {
        my ( $self, $irc, $nickstring, $channels, $message ) = @_;
        my ($nick) = split /!/, $$nickstring;
        my $iter = $self->search( { for => $nick } );
        while ( my $block = $iter->next ) {
            for my $msg (@$block) {
                $self->privmsg( $_ => $msg->string ) for @$$channels;
                $self->delete($msg);
            }
        }
        return PCI_EAT_NONE;
    }
}

1;
__END__

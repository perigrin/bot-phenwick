package bot-phenwick;
use Moses;
use namespace::autoclean;

server 'irc.perl.org';
nickname 'bot';
channels '#bot-test';



__PACKAGE__->meta->make_immutable;
1;
__END__

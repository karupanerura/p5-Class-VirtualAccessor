package Class::VirtualAccessor;
use strict;
use warnings;
our $VERSION = '0.01';

1;
__END__

=head1 NAME

Class::VirtualAccessor -

=head1 SYNOPSIS

  use Class::VirtualAccessor qw/hoge fuga hogefuga/;

  sub new {
      my $class = shift;
      my $args  = (@_ == 1) ? $_[0] : +{ @_ };

      bless(+{ %$args } => $class);
  }

  sub method {
      my $self = shift;

      $self->{hoge} = 'hogehoge';   # ok
      $self->{hoga} = 'hogehoge';   # typo! error!
  }

=head1 DESCRIPTION

Class::VirtualAccessor is

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

package Class::VirtualAccessor;
use strict;
use warnings;
our $VERSION = '0.01';

use Carp ();
use Variable::Magic ();

sub import {
    my $class  = shift;
    my $args   = (@_ == 1) ? $_[0] : +{ @_ };
    return if $args->{disable};

    my $caller = caller;
    my $bless = sub {
        croak('This module support HashRef only.') if(ref $_[0] ne 'HASH');
        my $obj = CORE::bless($_[0] => $_[1]);

        if (exists $args->{ro}) {
            my $wiz = Variable::Magic::wizard(set => sub { Carp::croak('This variable is read only.') });
            foreach my $name ( @{$args->{ro}} ) {
                Variable::Magic::cast($obj->{$name}, $wiz);
            }
        }
        if (exists $args->{wo}) {
            my $wiz = Variable::Magic::wizard(get => sub { Carp::croak('This variable is write only.') });
            foreach my $name ( @{$args->{wo}} ) {
                Variable::Magic::cast($obj->{$name}, $wiz);
            }
        }
        if (exists $args->{rw}) {
            foreach my $name ( @{$args->{rw}} ) {
                $obj->{$name} = undef unless exists $obj->{$name}; # touch
            }
        }

        my $wrap_wiz = Variable::Magic::wizard(
            fetch => sub { Carp::croak(qq{This variable "$_[2]" is not defined.}) unless exists $_[0]->{$_[2]} },
            store => sub { Carp::croak(qq{This variable "$_[2]" is not defined.}) unless exists $_[0]->{$_[2]} },
        );
        Variable::Magic::cast(%$obj, $wrap_wiz);

        return $obj;
    };

    {
        no strict 'refs';
        *{"${caller}::bless"} = $bless;
    }
}

1;
__END__

=head1 NAME

Class::VirtualAccessor - 

=head1 SYNOPSIS

  use Class::VirtualAccessor (
    rw => [qw/hoge fuga/],
    ro => [qw/foo/],
  );

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

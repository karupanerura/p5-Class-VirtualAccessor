package Class::VirtualAccessor;
use strict;
use warnings;

use 5.006_000;
our $VERSION = '0.01';

use Carp ();
use Variable::Magic ();
use Scalar::Util qw/reftype/;

sub import {
    my $class  = shift;
    my $args   = (@_ == 1) ? $_[0] : +{ @_ };

    my $caller = caller;

    my $with_vaccessor = sub {
        my $obj = shift;
        croak('This module support HashRef only.') if(reftype($obj) ne 'HASH');

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

    my $vbless = sub ($$) { ## no critic
        $with_vaccessor->(bless($_[0] => $_[1]));
    };

    {
        # export methods
        no strict 'refs';
        *{"${caller}::vbless"} = $args->{disable} ?
            \&bless:
            $vbless;
        *{"${caller}::with_vaccessor"} = $args->{disable} ?
            sub { $_[0] }:
            $with_vaccessor;
    }
}

1;
__END__

=head1 NAME

Class::VirtualAccessor - object variable access supporter

=head1 SYNOPSIS

  use Class::VirtualAccessor (
    rw => [qw/hoge fuga/],
    ro => [qw/foo/],
  );

  sub new {
      my $class = shift;
      my $args  = (@_ == 1) ? $_[0] : +{ @_ };

      vbless(+{ %$args } => $class);

      # or you can use this interface
      # bless(+{ %$args } => $class)->with_vaccessor;
  }

  sub method {
      my $self = shift;

      $self->{hoge} = 'hogehoge';   # ok
      $self->{hoga} = 'hogehoge';   # typo! error!
      $self->{foo}  = 'hogehoge';   # can't write! error!
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

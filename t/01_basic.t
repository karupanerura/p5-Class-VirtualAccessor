package Foo;
use Class::VirtualAccessor (
    ro => [qw/hoge/],
    wo => [qw/foobar/],
    rw => [qw/fuga/],
);

sub new {
    my $class = shift;
    my $args  = (@_ == 1) ? $_[0] : +{ @_ };

    vbless(+{ %$args } => $class);
}

package main;
use strict;
use warnings;
use Test::More tests => 12;
use Test::Exception;

my $obj;
lives_ok {
    $obj = Foo->new(hoge => 'fuga');
    is ref($obj), 'Foo', "is Foo's object";
} 'bless ok';
lives_ok { $obj->{fuga} = 'hoge' } 'rw variable write ok';
lives_ok { $obj->{foobar} = 'foobar' } 'wo variable write ok';
lives_ok {
    is $obj->{hoge}, 'fuga', 'read ok';
} 'ro variable write ok';
lives_ok { $obj->{fuga} } 'rw variable write ok';
lives_ok {
    $obj->{fuga} = $obj->{hoge};
    is $obj->{fuga}, 'fuga', 'read ok';
} 'rw variable write ok';
dies_ok { $obj->{fugo} } 'no defined variable';
dies_ok { $obj->{hoge} = $obj->{fuga} } 'ro variable write fail ok';
dies_ok { $obj->{foobar} } 'wo variable read fail ok';

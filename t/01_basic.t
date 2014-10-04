use strict;
use warnings;
use Test::More;

use Sub::Retry::Extended;

# there are same tests in Sub::Retry.

{
    my $i = 0;
    my $ret = retryX(
        times => 10,
        delay => 0,
        code => sub {
            die if $i++ != 5;
            return '4649';
        },
    );
    is $ret, '4649';
}

{
    my $i = 0;
    eval {
        retryX(
            times => 10,
            delay => 0,
            code => sub {
                die "FAIL";
            },
        );
    };
    like $@, qr/FAIL/;
    like $@, qr/\Q@{[ __FILE__ ]}/;
}

{
    my @x = retryX(
        times => 10,
        delay => 0,
        code => sub {
            wantarray ? (1,2,3) : 0721;
        },
    );
    is join(',', @x), '1,2,3';
}

{
    my $x = retryX(
        times => 10,
        delay => 0,
        code => sub {
            wantarray ? (1,2,3) : 0721;
        },
    );
    is $x, 0721;
}

{
    my $ok;
    retryX(
        times => 10,
        delay => 0,
        code => sub {
            $ok++ unless defined wantarray;
        },
    );
    ok $ok, 'void context';
}

{
    my $i;
    my $x = retryX(
        times => 10,
        delay => 0,
        code => sub {
            $i++;
        },
        retry_if => sub { 1 },
    );
    is $i, 10;
    ok !$x;
}

{
    my $x = retryX(
        times => 10,
        delay => 0,
        code => sub { 'ok' },
        retry_if => sub { $_[0] ne 'ok' ? 1 : 0 },
    );
    is $x, 'ok';
}

{
    my @x = retryX(
        times => 10,
        delay => 0,
        code => sub { (1, 2, 3); },
        retry_if => sub { my @ret = @_; join(':', @ret) eq '1:2:3' ? 0 : 1 },
    );
    is_deeply \@x, [qw/1 2 3/];
}

{
    no warnings 'redefine';
 
    my $count = 0;
    local *Sub::Retry::Extended::sleep = sub {
        $count++;
    };
 
    my $x = retryX(
        times => 10,
        delay => 0,
        code => sub {},
        retry_if => sub { 1 },
    );
    is $count, 9;
}

{
    my @numbers;
    my $i = 0;
    my @x = retryX(
        times => 10,
        delay => 0,
        code => sub {
            push @numbers, shift;
            die if ++$i < 10;
        },
    );
    is_deeply \@numbers, [1..10];
}

{
    my @numbers;
    my $i = 0;
    my $x = retryX(
        times => 10,
        delay => 0,
        code => sub {
            push @numbers, shift;
            die if ++$i < 10;
        },
    );
    is_deeply \@numbers, [1..10];
}

{
    my @numbers;
    my $i = 0;
    retryX(
        times => 10,
        delay => 0,
        code => sub {
            push @numbers, shift;
            die if ++$i < 10;
        },
    );
    is_deeply \@numbers, [1..10];
}

done_testing;

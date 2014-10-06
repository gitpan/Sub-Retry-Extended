use strict;
use warnings;
use Test::More;

use Sub::Retry::Extended;
use Time::HiRes qw/sleep/;

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 0,
            code => sub {
                $i++;
                sleep $i * 0.11;
                die;
            },
            each_timeout => 0.3,
        );
    };
    ok($i < 10);
    like $@, qr/^retry timeout: each/;
}

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 0,
            code => sub {
                $i++;
                sleep 0.3;
                die;
            },
            total_timeout => 1,
        );
    };
    ok($i < 10);
    like $@, qr/^retry timeout: total/;
}

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 0.05,
            code => sub {
                $i++;
                sleep 0.03;
                die;
            },
            total_timeout => 0.1,
        );
    };
    ok($i <= 2);
    like $@, qr/^retry timeout: total/;
}

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 2,
            code => sub {
                $i++;
                die;
            },
            each_timeout => 1,
        );
    };
    is $i, 1;
    like $@, qr/^retry timeout: each/;
}

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 2,
            code => sub {
                $i++;
                die;
            },
            each_timeout => 1,
            total_timeout => 1,
        );
    };
    is $i, 1;
    like $@, qr/^retry timeout: each/;
}

{
    my $ret;
    my $i = 0;
    eval {
        $ret = retryX(
            times => 10,
            delay => 2,
            code => sub {
                $i++;
                die;
            },
            each_timeout => 5,
            total_timeout => 1,
        );
    };
    is $i, 1;
    like $@, qr/^retry timeout: total/;
}

done_testing;

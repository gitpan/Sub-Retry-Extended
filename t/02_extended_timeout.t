use strict;
use warnings;
use Test::More;

use Sub::Retry::Extended;
use Time::HiRes qw/sleep/;

{
    my $i = 0;
    my $ret = retryX(
        times => 10,
        delay => 0,
        code => sub {
            $i++;
            sleep $i * 0.11;
            die;
        },
        each_timeout => 0.3,
    );
    is $i, 3;
}

{
    my $i = 0;
    my $ret = retryX(
        times => 10,
        delay => 0,
        code => sub {
            $i++;
            sleep 0.3;
            die;
        },
        total_timeout => 1,
    );
    is $i, 4;
}

{
    my $i = 0;
    my $ret = retryX(
        times => 10,
        delay => 0.05,
        code => sub {
            $i++;
            sleep 0.03;
            die;
        },
        total_timeout => 0.1,
    );
    is $i, 2;
}

done_testing;

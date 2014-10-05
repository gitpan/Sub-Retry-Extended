package Sub::Retry::Extended;
use strict;
use warnings;
use Carp qw/croak/;
use Time::HiRes qw/sleep gettimeofday tv_interval/;
use parent qw/Exporter/;

our @EXPORT = qw/retryX/;

our $VERSION = '0.04';

sub retryX {
    my (%args) = @_;

    my $code = delete($args{code}) or croak 'require code';
    if (ref $code ne 'CODE') {
        croak "'code' is not code ref";
    }
    my $times    = delete($args{times}) || 1;
    my $delay    = delete($args{delay}) || delete($args{wait}) || 0;
    my $retry_if = delete($args{retry_if});
    if ($retry_if && ref $retry_if ne 'CODE') {
        croak "'retry_if' is not code ref";
    }
    my $timeout = {
        each  => delete($args{each_timeout})  || 0,
        total => delete($args{total_timeout}) || 0,
    };

    # Most of below codes have been copied from Sub::Retry
    my $err;
    $retry_if ||= sub { $err = $@ };
    my $n = 0;
    my $lap = { start => [gettimeofday] };
    while ( $times-- > 0 ) {
        $n++;
        $lap->{each} = [gettimeofday];
        if (wantarray) {
            my @ret = eval { $code->($n) };
            unless ($retry_if->(@ret)) {
                return @ret;
            }
            _timeout($timeout, $lap);
        }
        elsif (not defined wantarray) {
            eval { $code->($n) };
            unless ($retry_if->()) {
                return;
            }
            _timeout($timeout, $lap);
        }
        else {
            my $ret = eval { $code->($n) };
            unless ($retry_if->($ret)) {
                return $ret;
            }
            _timeout($timeout, $lap);
        }
        sleep $delay if $times; # Do not sleep in last time
        _timeout($timeout, $lap);
    }
    die $err if $err;
}

sub _timeout {
    my ($timeout, $lap) = @_;

    if ( $timeout->{each}
            && tv_interval($lap->{each}) > $timeout->{each} ) {
        die 'retry timeout: each time';
    }

    if ( $timeout->{total}
            && tv_interval($lap->{start}) > $timeout->{total} ) {
        die 'retry timeout: total time';
    }

    return;
}

1;

__END__

=head1 NAME

Sub::Retry::Extended - extend retring-code


=head1 SYNOPSIS

    use Sub::Retry::Extended;
    use Cache::Memcached::Fast;

    my $cache = Cache::Memcached::Fast->new;

    my $ret = retryX(
        code => sub {
            $cache->get('foo');
        },
        retry_if => sub {
            my $res = shift;
            defined $res ? 0 : 1;
        },
        times => 3,
        delay => 0.1,
        each_timeout  => 1.5,
        total_timeout => 2.5,
    );


=head1 DESCRIPTION

Sub::Retry::Extended provides the C<retryX> function which has been extended interfaces from  L<Sub::Retry>.

=head1 METHOD

=head2 retryX(%hash)

below params are same as args of L<Sub::Retry> 's C<retry> function.

=over 4

=item * B<code> => \&code : required

=item * B<retry_if> => \&code : optional

=item * B<times> => $n_times : required

=item * B<delay> => $second // 0

=back

below params are extended.

=over 4

=item * B<each_timeout> => $second : optional

=item * B<total_timeout> => $second : optional

=back

B<NOTE> that if timeout was invoked, die with an 'retry timeout' message.


=head1 REPOSITORY

Sub::Retry::Extended is hosted on github: L<http://github.com/bayashi/Sub-Retry-Extended>

Welcome your patches and issues :D


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

L<Sub::Retry>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    name                => 'Sub-Retry-Extended',
    module_name         => 'Sub::Retry::Extended',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/Sub/Retry/Extended.pm',
    configure_requires  => {
        'Module::Build' => 0.38,
    },
    build_requires      => {
        'Test::More' => 0.88,
    },
    requires => {
        'perl' => '5.008001',
        'Carp' => 0,
        'Time::HiRes' => 0,
        'parent' => 0,
        'Exporter' => 0,
    },
    add_to_cleanup      => [ 'Sub-Retry-Extended-*' ],
    meta_merge     => {
      resources => {
        repository  => 'http://github.com/bayashi/Sub-Retry-Extended',
        bugtracker  => 'http://github.com/bayashi/Sub-Retry-Extended/issues',
      }
    },
    recursive_test_files => 1,
    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? ['t/', 'xt/'] : ['t/'],
);

$builder->create_build_script();

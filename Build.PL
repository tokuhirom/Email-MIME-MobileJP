use strict;
use warnings FATAL => 'all';
use Module::Build;

my $build = Module::Build->new(
    license              => 'perl',
    recursive_test_files => 1,
    dynamic_config       => 0,
    build_requires       => {
        'Test::Requires' => '0',
        'Test::More'     => '0.98'
    },
    configure_requires => { 'Module::Build' => '0.38' },
    requires           => {
        'perl'                       => '5.008001',
        'parent'                     => '0',
        'Encode::JP::Mobile'         => '0.27',
        'Email::MIME'                => '1.906',
        'Email::Address::JP::Mobile' => '0.05',
        'Email::Address::Loose'      => '0.01',
        'Tiffany'                    => '0.03',
        'Encode'                     => '2.4',
        'Email::Address'             => '1.892'
    },
    no_index    => { 'directory' => [ 't', 'inc' ] },
    name        => 'Email-MIME-MobileJP',
    module_name => 'Email::MIME::MobileJP',

    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',

    create_readme  => 1,
    create_license => 1,
);
$build->create_build_script();

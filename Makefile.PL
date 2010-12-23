use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Email-MIME-MobileJP';
all_from 'lib/Email/MIME/MobileJP.pm';

requires 'Email::Address' => 1.892;
requires 'Email::Address::JP::Mobile' => 0.05; # mobile carrier detection from e-mail address.
requires 'Email::Address::Loose' => 0.01; # for fucking docomo's RFC violated E-Mail address.
requires 'Email::MIME' => 1.906;

requires 'Encode' => 2.40;
requires 'Encode::JP::Mobile' => 0.27;

requires 'Tiffany' => 0.03;
requires 'parent';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
test_requires 'Test::Requires';
author_tests('xt');
WriteAll;

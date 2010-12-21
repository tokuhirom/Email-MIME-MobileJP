use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Email-MIME-MobileJP';
all_from 'lib/Email/MIME/MobileJP.pm';

requires 'Email::Address';
requires 'Email::Address::JP::Mobile'; # mobile carrier detection from e-mail address.
requires 'Email::Address::Loose'; # for fucking docomo's RFC violated E-Mail address.
requires 'Email::Date::Format';
requires 'Email::MIME';

requires 'Encode';
requires 'Encode::JP::Mobile';

requires 'Tiffany';
requires 'parent';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
test_requires 'Test::Requires';
author_tests('xt');
WriteAll;

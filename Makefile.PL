use inc::Module::Install;
name 'AuthSub';
all_from 'lib/AuthSub.pm';

requires 'Ark';
requires 'Net::Google::AuthSub';
requires 'Net::Google::DataAPI' => '0.09';
requires 'Net::Google::Spreadsheets' => '0.07';
requires 'YAML';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;

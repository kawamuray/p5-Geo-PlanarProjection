use inc::Module::Install;
name 'Geo-PlanarProjection';
all_from 'lib/Geo/PlanarProjection.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

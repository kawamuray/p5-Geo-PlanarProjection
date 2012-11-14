use inc::Module::Install;
name 'Geo-PlanarProjection';
all_from 'lib/Geo/PlanarProjection.pm';

# requires '';

tests 't/*.t';

test_requires 'Test::More';

readme_markdown_from 'lib/Geo/PlanarProjection.pm';

auto_include;
WriteAll;

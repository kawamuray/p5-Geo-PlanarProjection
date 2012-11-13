use strict;
use warnings;
use Test::More;
use t::Util;

use Geo::Map::PlanarProjection;

subtest "Method new" => sub {
    ok my $gmpp = Geo::Map::PlanarProjection->new;
    isa_ok $gmpp, 'Geo::Map::PlanarProjection';

    ok $gmpp = Geo::Map::PlanarProjection->new(zoom => 10);
    isa_ok $gmpp, 'Geo::Map::PlanarProjection';
};

done_testing;

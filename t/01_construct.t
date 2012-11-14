use strict;
use warnings;
use Test::More;
use t::Util;

use Geo::PlanarProjection;

subtest "Method new" => sub {
    ok my $gmpp = Geo::PlanarProjection->new;
    isa_ok $gmpp, 'Geo::PlanarProjection';

    ok $gmpp = Geo::PlanarProjection->new(zoom => 10);
    isa_ok $gmpp, 'Geo::PlanarProjection';
};

done_testing;

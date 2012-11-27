use strict;
use warnings;
use Test::More;
use t::Util;

use Geo::PlanarProjection;

subtest "Construct new instance" => sub {
    ok my $pproj = Geo::PlanarProjection->new;
    isa_ok $pproj, 'Geo::PlanarProjection';

    ok $pproj = Geo::PlanarProjection->new(zoom => 10);
    isa_ok $pproj, 'Geo::PlanarProjection';
};

done_testing;

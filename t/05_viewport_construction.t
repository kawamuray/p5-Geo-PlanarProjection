use strict;
use warnings;
use Test::More;
use t::Util;

subtest "Construction" => sub {
    ok my $vp = Geo::PlanarProjection::Viewport->new(
        width  => 800,
        height => 800,
        clat   => 35.692995,
        clng   => 139.704094,
        zoom   => 10,
    );

    isa_ok $vp, 'Geo::PlanarProjection::Viewport';
};

done_testing;

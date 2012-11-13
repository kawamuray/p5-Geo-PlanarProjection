use strict;
use warnings;
use Test::More;
use t::Util;

subtest "latlng -> pixel xy" => sub {
    my $gmpp = new_instance;

    is $gmpp->lat2y( 85.05112878),    0;
    is $gmpp->lat2y( 85.05112878, 0), 0;
    is $gmpp->lat2y(-85.05112878),    256;
    is $gmpp->lat2y(-85.05112878, 0), 256;

    is $gmpp->lng2x(-180),    0;
    is $gmpp->lng2x(-180, 0), 0;
    is $gmpp->lng2x( 180),    256;
    is $gmpp->lng2x( 180, 0), 256;

    is $gmpp->lng2x(138), 226.13333333;
    is $gmpp->lat2y(35),  101.40104481;

    $gmpp = new_instance(19);
    is $gmpp->lng2x(180),              134_217_728;
    is $gmpp->lng2x(180, 19),          134_217_728;
    is $gmpp->lat2y(-85.05112878),     134_217_728;
    is $gmpp->lat2y(-85.05112878, 19), 134_217_728;
};

subtest "pixel xy -> latlng" => sub {
    my $gmpp = new_instance;

    is $gmpp->x2lng(0),    -180;
    is $gmpp->x2lng(0, 0), -180;
    is $gmpp->y2lat(0),    85.05112878;
    is $gmpp->y2lat(0, 0), 85.05112878;

    is $gmpp->x2lng(256),    180;
    is $gmpp->x2lng(256, 0), 180;
    is $gmpp->y2lat(256),    -85.05112878;
    is $gmpp->y2lat(256, 0), -85.05112878;

    is $gmpp->x2lng(255.9),    179.859375;
    is $gmpp->x2lng(255.9, 0), 179.859375;
    is $gmpp->y2lat(255.9),    -85.03898268;
    is $gmpp->y2lat(255.9, 0), -85.03898268;
};

done_testing;

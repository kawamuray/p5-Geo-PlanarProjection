use strict;
use warnings;
use Test::More;
use t::Util;

subtest "latlng -> pixel xy" => sub {
    my $pproj = new_instance;

    my $cvt = $pproj->converter(
        from => 'lat',
        to   => 'pixel',
    );

    is $cvt->( 85.05112878), 0;
    is $cvt->(-85.05112878), 256;
    is $cvt->(35),           101.40104481;

    $cvt = $pproj->converter(
        from => 'lng',
        to   => 'pixel',
    );

    is $cvt->(-180), 0;
    is $cvt->(180),  256;
    is $cvt->(138),  226.13333333;

    $cvt = $pproj->converter(
        from => 'lng',
        to   => 'pixel',
        zoom => 19,
    );
    is $cvt->(180),     134_217_728;
    is $cvt->(180, 19), 134_217_728;

    $cvt = $pproj->converter(
        from => 'lat',
        to   => 'pixel',
        zoom => 19,
    );
    is $cvt->(-85.05112878),     134_217_728;
    is $cvt->(-85.05112878, 19), 134_217_728;
};

subtest "pixel xy -> latlng" => sub {
    my $gmpp = new_instance;

    is $gmpp->x_to_lng(0),    -180;
    is $gmpp->x_to_lng(0, 0), -180;
    is $gmpp->y_to_lat(0),    85.05112878;
    is $gmpp->y_to_lat(0, 0), 85.05112878;

    is $gmpp->x_to_lng(256),    180;
    is $gmpp->x_to_lng(256, 0), 180;
    is $gmpp->y_to_lat(256),    -85.05112878;
    is $gmpp->y_to_lat(256, 0), -85.05112878;

    is $gmpp->x_to_lng(255.9),    179.859375;
    is $gmpp->x_to_lng(255.9, 0), 179.859375;
    is $gmpp->y_to_lat(255.9),    -85.03898268;
    is $gmpp->y_to_lat(255.9, 0), -85.03898268;
};

done_testing;

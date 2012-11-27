use strict;
use warnings;
use Test::More;
use t::Util;

subtest "latlng -> pixel xy" => sub {
    my $pproj = new_instance;

    my $cvt = $pproj->converter('lat' => 'pixel_y');

    is $cvt->( 85.05112878), 0;
    is $cvt->(-85.05112878), 256;

    is $cvt->(35),           101.40104481;
    is $pproj->convert('lat' => 'pixel_y', 35), 101.40104481;

    $cvt = $pproj->converter('lng' => 'pixel_x');

    is $cvt->(-180), 0;
    is $cvt->(180),  256;
    is $cvt->(138),  226.13333333;
    is $pproj->convert('lng' => 'pixel_x', 138), 226.13333333;

    $cvt = $pproj->converter('lng' => 'pixel_x', { zoom => 19 });

    is $cvt->(180),     134_217_728;
    is $pproj->convert('lng' => 'pixel_x', { zoom => 19 }, 180), 134_217_728;

    $cvt = $pproj->converter('lat' => 'pixel_y', { zoom => 19 });

    is $cvt->(-85.05112878),     134_217_728;
    is $pproj->convert('lng' => 'pixel_x', { zoom => 19 }, 180), 134_217_728;
};

subtest "pixel xy -> latlng" => sub {
    my $pproj = new_instance;

    my $cvt = $pproj->converter('pixel_x' => 'lng');

    is $cvt->(0),        -180;
    is $cvt->(256),      180;
    is $cvt->(255.9),    179.859375;
    is $pproj->convert('pixel_x' => 'lng', 255.9), 179.859375;

    $cvt = $pproj->converter('pixel_y' => 'lat');

    is $cvt->(0),        85.05112878;
    is $cvt->(256),      -85.05112878;
    is $cvt->(255.9),    -85.03898268;
    is $pproj->convert('pixel_y' => 'lat', 255.9), -85.03898268;
};

done_testing;

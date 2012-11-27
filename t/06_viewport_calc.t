use strict;
use warnings;
use Test::More;
use t::Util;

subtest "End points" => sub {
    my $vp = new_viewport;

    is $vp->leftend, 232401.41671424;
    is $vp->topend,  102815.99967232;
};

subtest "Calculate image X,Y coordinate from lat,lng" => sub {
    my $vp = new_viewport;
    is $vp->convert('lat' => 'view_y', 35.630512),  456.000317440004;
    is $vp->convert('lng' => 'view_x', 139.880562), 528.500080639991;
};

subtest "Calculate lat,lng from image X,Y" => sub {
    my $vp = new_viewport;
    is $vp->convert('view_y' => 'lat', 528), 35.5501057;
    is $vp->convert('view_x' => 'lng', 456), 139.7809983;
};

subtest "Calculate viewport range" => sub {
    my $vp = new_viewport;

    is_deeply [ $vp->range ], [
        [ 232401.41671424, 233201.41671424 ],
        [ 102815.99967232, 103615.99967232 ],
    ];

    is_deeply [ $vp->range_latlng ], [
        [ 36.13787508,  35.24561946 ],
        [ 139.15477759, 140.2534104 ],
    ];

    is_deeply [ $vp->range_tile ], [
        [ 907, 911 ],
        [ 401, 405 ],
    ];
};

done_testing;

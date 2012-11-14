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
    is $vp->lat_to_imy(35.630512),  456.000317440004;
    is $vp->lng_to_imx(139.880562), 528.500080639991;
};

subtest "Calculate lat,lng from image X,Y" => sub {
    my $vp = new_viewport;
    is $vp->imy_to_lat(528), 35.5501057;
    is $vp->imx_to_lng(456), 139.7809983;
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
};

done_testing;

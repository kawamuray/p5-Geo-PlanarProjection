use strict;
use warnings;
use Test::More;

use t::Util;

use Geo::PlanarProjection;

subtest "_round8" => sub {
    my $round8 = \&Geo::PlanarProjection::_round8;

    is $round8->(10.010101014), 10.01010101;
    is $round8->(10.010101015), 10.01010102;
    is $round8->(10.01010104),  10.01010104;
    is $round8->(10.01010105),  10.01010105;
};

subtest "_pow2of" => sub {
    my $pow2of = \&Geo::PlanarProjection::_pow2of;

    # Trying double times to confirm the result when its cached
    for (0..1) {
        for my $i (0..19) {
            is $pow2of->($i), 2**$i;
        }
    }
};

done_testing;

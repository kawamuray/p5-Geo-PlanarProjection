use strict;
use warnings;
use Test::More;
use t::Util;

subtest "pixel -> tile" => sub {
    my $ggc = new_instance;

    is $ggc->tileindexof(0),   0;
    is $ggc->tileindexof(128), 0;

    $ggc = new_instance(zoom => 1);
    is $ggc->tileindexof(0),   0;
    is $ggc->tileindexof(128), 0;
    is $ggc->tileindexof(256), 1;
};

# subtest "pixel -> coordinates in tile" => sub {
#     my $ggc = new_instance;

# #     is $ggc->pixel2tile_surplus(0),   0;
# #     is $ggc->pixel2tile_surplus(128), 128;
# #     is $ggc->pixel2tile_surplus(129), 129;

# #     $ggc->zoom(1);
# #     is $ggc->pixel2tile_surplus(0),   0;
# #     is $ggc->pixel2tile_surplus(256), 0;
# #     is $ggc->pixel2tile_surplus(257), 1;
# };

# subtest "tile_viewport" => sub {
#     my $ggc = new_instance;

#     my %pixel_viewport = (
#         left   => 105,
#         top    => 105,
#         right  => 205,
#         bottom => 205,
#     );

#     is_deeply $ggc->tile_viewport(%pixel_viewport), +{
#         tx_beg => 0,
#         ty_beg => 0,
#         tx_end => 0,
#         ty_end => 0,
#     };


#     %pixel_viewport = (
#         left   => 105,
#         top    => 105,
#         right  => 305,
#         bottom => 305,
#     );
#     $ggc->zoom(1);
#     is_deeply $ggc->tile_viewport(%pixel_viewport), +{
#         tx_beg => 0,
#         ty_beg => 0,
#         tx_end => 1,
#         ty_end => 1,
#     };
# };

done_testing;

use strict;
use warnings;
use Test::More;
use t::Util;

subtest "pixel -> tile" => sub {
    my $pproj = new_instance;

    my $cvt = $pproj->converter('pixel_x' => 'tileindex');

    is $cvt->(0),   0;
    is $cvt->(128), 0;

    $cvt = $pproj->converter('pixel_y' => 'tileindex', { zoom => 19 });
    is $cvt->(0),   0;
    is $cvt->(128), 0;
    is $cvt->(256), 1;
};

done_testing;

package t::Util;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw/
  new_instance
  new_viewport
/;

use Geo::PlanarProjection;
use Geo::PlanarProjection::Viewport;

sub new_instance { Geo::PlanarProjection->new(@_) }

sub new_viewport {
    Geo::PlanarProjection::Viewport->new(
        width  => 800,
        height => 800,
        clat   => 35.692995,
        clng   => 139.704094,
        zoom   => 10,
        @_,
    )
}

1;

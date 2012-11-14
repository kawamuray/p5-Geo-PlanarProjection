package Geo::PlanarProjection::Viewport;
use strict;
use warnings;
use Carp;

use Geo::PlanarProjection;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->{width}  = delete $args{width};
    $self->{height} = delete $args{height};
    $self->{clat}   = delete $args{clat};
    $self->{clng}   = delete $args{clng};
    $self->{zoom}   = delete $args{zoom};

    if (%args) {
        croak "Unkown options where specified: ".join ',', keys %args;
    }

    $self->{leftend} = $self->pproj->lng_to_x($self->clng) - $self->width / 2;
    $self->{topend} = $self->pproj->lat_to_y($self->clat) - $self->height / 2;

    $self;
}

sub width   { (shift)->{width}   }
sub height  { (shift)->{height}  }
sub clat    { (shift)->{clat}    }
sub clng    { (shift)->{clng}    }
sub zoom    { (shift)->{zoom}    }
sub leftend { (shift)->{leftend} }
sub topend  { (shift)->{topend}  }

sub pproj {
    my $self = shift;
    $self->{pproj} ||= Geo::PlanarProjection->new(zoom => $self->zoom);
}

sub lng_to_vx {
    my ($self, $lng) = @_;
    $self->pproj->lng_to_x($lng) - $self->leftend;
}

sub lat_to_vy {
    my ($self, $lat) = @_;
    $self->pproj->lat_to_y($lat) - $self->topend;
}

sub vx_to_lng {
    my ($self, $vx) = @_;
    $self->pproj->x_to_lng($vx + $self->leftend);
}

sub vy_to_lat {
    my ($self, $vy) = @_;
    $self->pproj->y_to_lat($vy + $self->topend);
}

sub range {
    my $self = shift;

    my @xrange = ($self->leftend, $self->leftend + $self->width);
    my @yrange = ($self->topend,  $self->topend + $self->height);

    (\@xrange, \@yrange);
}

sub range_latlng {
    my $self = shift;

    (
        [ $self->vy_to_lat(0), $self->vy_to_lat($self->height) ],
        [ $self->vx_to_lng(0), $self->vx_to_lng($self->width)  ],
    );
}

sub range_tile {
    my $self = shift;

    my ($xrange, $yrange) = $self->range;

    my $pproj = $self->pproj;
    (
        [ $pproj->tileindexof($xrange->[0]), $pproj->tileindexof($xrange->[1]) + 1 ],
        [ $pproj->tileindexof($yrange->[0]), $pproj->tileindexof($yrange->[1]) + 1 ],
    );
}

1;
__END__

=head1 NAME

Geo::PlanarProjection::Viewport - Viewport specific calculation using Geo:PlanarProjection

=head1 SYNOPSIS

  use Geo::PlanarProjection::Viewport;

  my $vp = Geo::PlanarProjection::Viewport->new(
      width  => 800,   # viewport width in pixel
      height => 800,   # viewport height in pixel
      clat   => 35.0,  # viewport center lat
      clng   => 135.0, # viewport center lng
      zoom => 10,      # zoom level for this viewport
  );

  $vp->leftend;        # Left end coordinates in pixel coordinates
  $vp->topend;         # Top end coordinates in pixel coordinates

  # Calculate coordinates on viewport from lat,lng
  my $vx = $vp->lng_to_vx(135.0);      #=> 400
  my $vy = $vp->lng_to_vy(35.0);       #=> 400

  # Possibly the negative number or the number larger than width or height
  # if lat or lng is out of range of this viewport
  $vp->lng_to_vx(135.9);                #=> 1055.35999999999
  $vp->lat_to_vy(35.9);                 #=> -404.512512000001

  # Inverse calculation from vx,vy to lat,lng
  $vp->vx_to_lng(400);                  #=> 135.0
  $vp->vy_to_lat(400);                  #=> 35.0

  # Get a range that is visible in this viewport
  # In pixel coordinates
  my ($xrange, $yrange) = $vp->range;
  my ($xmin, $xmax) = @$xrange;
  my ($ymin, $ymax) = @$yrange;

  # In lat,lng
  my ($latrange, $lngragne) = $vp->range_latlng;
  my ($upper_lat, $lower_lat) = @$latrange;
  my ($lefter_lng, $righter_lng) = @$lngrange;

  # In tile index
  my ($txrange, $tyrange) = $vp->range_tile;
  my ($txmin, $txmax) = @$txrange;
  my ($tymin, $tymax) = @$tyrange;

=head1 DESCRIPTION

Geo::PlanarProjection::Viewport is a module to handle planar projection in viewport(e.g. NxM pixel image)
using Geo::PlanarProjection.

This module can use to try making a map or something that needs to convert coordinates
from lat,lng to coordinates that can be render to plane surface.

You can specify viewport size, center coordinates that is the center where you want to display in the screen
and the zoom level for scaling geodetic objects.

You must read the document of Geo::PlanarProjection to understand projection system and coordinates system
used in this module.

=head2 VIEWPORT COORDINATES

In this module, vx,vy is a abbreviation for viewport_x and viewport_y.

Viewport is a width * height size plane surface that displays area determined by
width, height, center coordinates and zoom level.

For example, let width be 800, let height be 800, let clat be 35.0, let clng be 135.0 and let zoom be 10.

Center (lat,lng) is (35.0, 135.0). In the pixel coordinates:

  center_x = 229376
  center_y = 103834.66988544

This can be calculated by using latlng_to_xy() method of Geo::PlanarProjection.

Left x and top y of this viewport is:

  left_x = center_x - width / 2  = 228976
  top_y  = center_y - height / 2 = 103434.66988544

Right x and bottom y of this viewport is:

  right_x  = left_x + width = 229776
  bottom_y = top_y + height = 104234.66988544

Finally, following table is a correspondence of pixel coordinates, latlng, viewport coordinates
in this viewport context:

  -----------------------------------------------------------------------------------
  |              |       pixel x,y        | lat,lng                  | viewport x,y |
  -----------------------------------------------------------------------------------
  | center       | 229376,103834.66988544 | 35.0,135.0               | 400,400      |
  -----------------------------------------------------------------------------------
  | left,top     | 228976,103434.66988544 | 35.44873411,134.45068359 | 0,0          |
  -----------------------------------------------------------------------------------
  | right,bottom | 229776,104234.66988544 | 34.54879151,135.54931641 | 800,800      |
  -----------------------------------------------------------------------------------

X or Y value of viewport coordinates can be used directory to render some object to
image or something that has a same size of viewport.

=head1 METHODS

=head2 new()

Create a blessed object of Geo::PlanarProjection::Viewport.

  my $pproj = Geo::PlanarProjection->new(zoom => 10);

You must specify the following arguments representing profile of viewport.

=head3 Arguments

=over

=item width

Width of this viewport in pixel size.

=item height

Height of this viewport in pixel size.

=item clat

Center lat of this viewport.

=item clng

Center lng of this viewport.

=item zoom

Zoom level of this viewport.
I recommend to keep zoom level for between 0 and 19.(as a GoogleMaps regulation)

=back

=head2 leftend()

Get a left end coordinates in pixel coordinates.

=head2 topend()

Get a top end coordinates in pixel coordinates.

=head2 pproj()

Get a Geo::PlanarProjection object that was initialized by zoom level of this viewport.

=head2 lng_to_vx()

Calculate the x coordinates on viewport by lng.

  my $x = $pproj->lng_to_vx($lng);

=head2 lat_to_vy()

Calculate the y coordinates on viewport by lat.

  my $y = $pproj->lat_to_vy($lat);

=head2 vx_to_lng()

Calculate the lng of a x on viewport.

  my $x = $pproj->x_to_lng($vx);

=head2 vy_to_lat()

Calculate the lat of a y on viewport.

  my $y = $pproj->y_to_lat($vy);

=head1 AUTHOR

Yuto KAWAMURA(kawamuray) E<lt>kawamuray.dadada {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

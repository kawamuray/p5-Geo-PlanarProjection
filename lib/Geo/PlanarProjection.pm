package Geo::PlanarProjection;
use strict;
use warnings;
use Carp;
use Math::Trig qw/ pi rad2deg deg2rad sinh /;

our $VERSION = '0.01';

our $R            = 128 / pi;
our $DEFAULT_ZOOM = 0;
our $TILE_SIZE    = 256;

sub new {
    my ($class, $src, $dst, $opts) = @_;

    my $internalize = $class->can("_from_$src")
        or croak "Unkown source: $src";
    my $externalize = $class->can("_to_$dst")
        or croak "Unkown destination: $dst";

    bless {
        internalizer => $internalize,
        externalizer => $externalize,
        zoom         => $opts->{zoom} // $DEFAULT_ZOOM,
    }, $class;
}

sub internalizer { (shift)->{internalizer} }
sub externalizer { (shift)->{externalizer} }
sub zoom         { (shift)->{zoom}         }

sub convert {
    my ($self, %args) = @_;

    my $intz = $self->internalizer;
    my $extz = $self->externalizer;

    $self->externalizer->(
        $self, $self->internalizer->($self, %args)
    );
}

sub _from_latlng {
    my ($self, %args) = @_;

    ($self->_calc_x($args{lng} // 0.0), $self->_calc_y($args{lat} // 0.0));
}

sub _calc_x {
    my ($self, $lng) = @_;

    _round8( $R * (deg2rad($lng) + pi) );
}

sub _calc_y {
    my ($self, $lat) = @_;

    my $sinradlat = sin(deg2rad($lat));
    _round8( -($R/2) * log( (1 + $sinradlat) / (1 - $sinradlat) ) + 128 );
}

sub _to_latlng {
    my ($self, $x, $y) = @_;

    +{ lat => $self->_calc_lat($y), lng => $self->_calc_lng($x) };
}

sub _calc_lng {
    my ($self, $x) = @_;

    _round8( rad2deg( $x / $R - pi ) );
}

sub _calc_lat {
    my ($self, $y) = @_;

    _round8( rad2deg( atan2(sinh( (128 - $y) / $R ), 1) ) );
}

sub _from_global {
    my ($self, %args) = @_;

    map { ($_ // 0.0) / _pow2of($self->zoom) } @args{qw/ x y /};
}

sub _to_global {
    my ($self, $x, $y) = @_;

    my ($px, $py) = map { $_ * _pow2of($self->zoom) } ($x, $y);
    +{ x => $px, y => $py };
}

sub _from_tile {
    my ($self, %args) = @_;

    map { ( ($_ // 0.0) * $TILE_SIZE ) / _pow2of($self->zoom) } @args{qw/ x y /};
}

sub _to_tile {
    my ($self, $x, $y) = @_;

    my ($tx, $ty) = map { int( $_ * _pow2of($self->zoom) / $TILE_SIZE ) } ($x, $y);
    +{ x => $tx, y => $ty };
}

my @POW2CACHE;
sub _pow2of {
    my $zoom = shift;
    $POW2CACHE[$zoom] ||= 2 ** $zoom;
}

sub _round8 { sprintf("%.8f", $_[0]) + 0 }

1;
__END__

=head1 NAME

Geo::PlanarProjection - Perl extension for calculate plane coordinates from lat,lng or do inverse

=head1 SYNOPSIS

  use Geo::PlanarProjection;

  my $pproj = Geo::PlanarProjection->new(zoom => 10);

  my $x = $pproj->convert('lng' => 'pixel_x', 135.0);                     #=> 229376
  my $y = $pproj->convert('lat' => 'pixel_y', 34.0);                      #=> 104718.26727936

  or get a converter if you may convert multiple values

  my $lng_to_x = $pproj->converter('lng' => 'pixel_x');
  my $y = $lng_to_x->(135.0);                                             #=> 104718.26727936

  my ($x, $y) = $pproj->convert('latlng' => 'pixel_xy', 34.0, 135.0);     #=> (229376, 104718.26727936)

  my $lat = $pproj->convert('pixel_y' => 'lat', $y);                      #=> 34.0
  my $lng = $pproj->convert('pixel_x' => 'lng', $x);                      #=> 135.0

  my $xy_to_latlng = $pproj->converter('pixel_xy' => 'latlng');
  my ($lat, $lng) = $xy_to_latlng->($x, $y);                              #=> (34.0, 135.0)

  # X-dimensional tile index
  my $tx = $pproj->convert('pixel_x' => 'tileindex', $x);                 #=> 896
  # Y-dimensional tile index
  my $ty = $pproj->convert('pixel_y' => 'tileindex', $y);                 #=> 409

=head1 DESCRIPTION

Geo::PlanarProjection is a module for calculate plane coordinates from lat,lng or do inverse.

This module can use to try making a map or something that needs to convert coordinates
from lat,lng to coordinates that can be render to plane surface.

=head2 COORDINATES SYSTEM

I adopted the coordinates system for this module that is almostly like to a system that used for GoogleMaps.
It is a very simple logic to project earth sphere to plane surface.

First, you need to know about the "World Coordinates".

World coordinates is originaly defined by Google to represents entire the earth
in a plane surface that has upperleft(0, 0) and lowerright(256, 256) corner.

In world coordinates, (x,y)=(0,0) is correspond to (lat,lng)=(85.0511287798066,-180),
(x,y)=(256,256) is correspond to (lat,lng)=(-85.0511287798066,180).
That means this module cannot handle coordinates out of range for
lat between 85.0511287798066 and -85.0511287798066, for lng between -180 and 180.

Second, you need to know about the "Pixel Coordinates".

Pixel coordinates is a world coordinates with considering "zoom" coefficient.
In the GoogleMaps world, zoom level is used between 0 and 19.

Pixel coordinates is completely correspond to world coordinates when that zoom level is 0.
Otherwise, pixel coordinates can be expressed by following equation.

  x_pixel = x_world * 2^zoomlevel
  y_pixel = y_world * 2^zoomlevel

In this module, simply x or y is a abbreviation for x_pixel or y_pixel.

=head2 EQUATION

World coordinates can be calculate by following equation.
Let R be 128 / PI.

  x_world = f(lng) = R * (lng + PI)
  y_world = g(lat) = -(R / 2) * log( (1 + sin(lat)) / (1- sin(lat)) ) + 128

In inverse.

  lng = f^-1(x) = x / R - PI
  lat = g^-1(y) = tan^-1( sinh((128-y) / R) )

=head1 METHODS

=head2 new()

Create a blessed object of Geo::PlanarProjection
You can specify a zoom as option.(If not, the value of $Geo::PlanarProjection::DEFAULT_ZOOM will be adopted)
Specified zoom level will used as default value when you not specified the zoom level for each call of follwing methods.

  my $pproj = Geo::PlanarProjection->new(zoom => 10);

I recommend to keep zoom level for between 0 and 19.(as a GoogleMaps regulation)

=head2 converter()

Create and return a subroutine that can be used to convert some value from A to B.

  my $lng_to_px   = $self->converter('lng' => 'pixel_x');
  my $lng_to_px19 = $self->converter('lng' => 'pixel_x', { zoom => 19 });

=head3 Conversion patterns

The specifications for A and B are arranged at following list.

=over

=item - lat => pixel_y

=item - lng => pixel_x

=item - latlng => pixel_xy

=item - pixel_x => lng

=item - pixel_y => lat

=item - pixel_xy => latlng

=item - pixel_x => tileindex

=item - pixel_y => tileindex

=back

=head3 Options

Currently, following options are supported.

=over

=item o zoom

Specify zoom level used to calculate conversion.

=back

=head2 convert()

Create and call converter by arguments specification.

  my $x   = $pproj->convert('lng' => 'pixel_x', 138.0);
  my $x19 = $pproj->convert('lng' => 'pixel_x', { zoom => 19 }, 138.0);

  $pproj->convert('lat' => 'pixel_y', 34.0);

is a equivalent to

  $pproj->converter('lat' => 'pixel_y')->(34.0);

See the above section converter() for more detials about options and conversion.

=head1 AUTHOR

Yuto KAWAMURA(kawamuray) E<lt>kawamuray.dadada {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

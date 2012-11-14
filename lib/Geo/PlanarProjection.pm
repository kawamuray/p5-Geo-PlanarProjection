package Geo::PlanarProjection;
use strict;
use warnings;
use Carp;
use Math::Trig qw/ pi rad2deg deg2rad sinh /;

our $VERSION = '0.01';

our $R = 128 / pi;
our $DEFAULT_ZOOM = 0;
our $TILE_SIZE    = 256;

sub new {
    my ($class, %opts) = @_;
    bless { zoom => $opts{zoom} // $DEFAULT_ZOOM }, $class;
}

my @POW2CACHE;
sub _pow2of {
    my $zoom = shift;
    $POW2CACHE[$zoom] ||= 2 ** $zoom;
}

sub _round8 { sprintf("%.8f", $_[0]) + 0 }

sub _zoomlv {
    my ($self, $zoom) = @_;
    _pow2of($zoom // $self->{zoom});
}

sub lng_to_x {
    my ($self, $lng, $zoom) = @_;

    _round8(
        $R * (deg2rad($lng) + pi)
    ) * $self->_zoomlv($zoom);
}

sub lat_to_y {
    my ($self, $lat, $zoom) = @_;

    my $radlat = deg2rad($lat);
    _round8(
        -($R/2) * log( (1 + sin($radlat)) / (1 - sin($radlat)) ) + 128
    ) * $self->_zoomlv($zoom);
}

sub latlng_to_xy {
    my ($self, $lat, $lng, $zoom) = @_;

    ( $self->lng_to_x($lng, $zoom), $self->lat_to_y($lat, $zoom) );
}

sub x_to_lng {
    my ($self, $x, $zoom) = @_;

    _round8(
        rad2deg( $x / $self->_zoomlv($zoom) / $R - pi )
    );
}

sub y_to_lat {
    my ($self, $y, $zoom) = @_;

    _round8(
        rad2deg( atan2(sinh( (128 - $y / $self->_zoomlv($zoom)) / $R ), 1) )
    );
}

sub xy_to_latlng {
    my ($self, $x, $y, $zoom) = @_;

    ( $self->y_to_lat($y, $zoom), $self->x_to_lng($x, $zoom) );
}

sub tileindexof {
    my ($self, $pv) = @_;

    int( $pv / $TILE_SIZE );
}

sub tileindexofs {
    my ($self, $pv) = @_;

    ( $self->tileindexof($pv), $pv % $TILE_SIZE );
}

1;
__END__

=head1 NAME

Geo::PlanarProjection - Perl extension for calculate plane coordinates from lat,lng or do inverse

=head1 SYNOPSIS

  use Geo::PlanarProjection;

  my $pproj = Geo::PlanarProjection->new(zoom => 10);

  my $x = $pproj->lng_to_x(135.0);                     #=> 229376
  my $y = $pproj->lat_to_y(34.0);                      #=> 104718.26727936

  or

  my ($x, $y) = $pproj->latlng_to_xy(34.0, 135.0);    #=> (229376, 104718.26727936)

  my $lat = $pproj->y_to_lat($y);                     #=> 34.0
  my $lng = $pproj->x_to_lng($x);                     #=> 135.0

  or

  my ($lat, $lng) = $pproj->xy_to_latlng($x, $y);    #=> (34.0, 135.0)


  # X-dimensional tile index
  my $tx = $pproj->tileindex($x);                    #=> 896
  # Y-dimensional tile index
  my $ty = $pproj->tileindex($y);                    #=> 409

=head1 DESCRIPTION

Geo::PlanarProjection is a module for calculate plane coordinates from lat,lng or do inverse.

This module can use to try making a map or something that needs to convert coordinates
from lat,lng to coordinates that can be render to plane surface.

=head2 COORDINATES SYSTEM

I introduced the coordinates system for this module that is almostly like to a system that used for GoogleMaps.
It is a very simple logic to project earth sphere to plane surface.

First, you need to know about the "World Coordinates".

World coordinates is originaly defined by Google to represents entire the earth
in a plane surface that has upperleft(0, 0) and lowerright(256, 256) corner.

=head1 AUTHOR

Yuto KAWAMURA(kawamuray) E<lt>kawamuray.dadada {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

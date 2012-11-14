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
    my $class = shift;
    bless { zoom => $_[0] // $DEFAULT_ZOOM }, $class;
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
        $R * (deg2rad($_[1]) + pi)
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

Geo::PlanarProjection -

=head1 SYNOPSIS

  use Geo::PlanarProjection;

=head1 DESCRIPTION

Geo::PlanarProjection is

=head1 AUTHOR

Yuto KAWAMURA(kawamuray) E<lt>kawamuray.dadada {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

package Geo::PlanarProjection::Viewport;
use strict;
use warnings;
use Carp;

use Geo::PlanarProjection;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->{width} = delete $args{width}
        or croak "You must specify width";
    $self->{height} = delete $args{height}
        or croak "You must specify height";
    $self->{clat} = delete $args{clat}
        or croak "You must specify clat";
    $self->{clng} = delete $args{clng}
        or croak "You must specify clng";
    $self->{zoom} = delete $args{zoom}
        // croak "You must specify zoom";

    if (%args) {
        croak "Unkown options where specified: ".join ',', keys %args;
    }

    $self->{gmpp} = Geo::PlanarProjection->new($self->{zoom});

    $self;
}

sub leftend {
    my $self = shift;
    $self->{gmpp}->lng_to_x($self->{clng}) - $self->{width} / 2;
}

sub topend {
    my $self = shift;
    $self->{gmpp}->lat_to_y($self->{clat}) - $self->{height} / 2;
}

sub lng_to_imx {
    my ($self, $lng) = @_;
    $self->{gmpp}->lng_to_x($lng) - $self->leftend;
}

sub lat_to_imy {
    my ($self, $lat) = @_;
    $self->{gmpp}->lat_to_y($lat) - $self->topend;
}

sub imx_to_lng {
    my ($self, $imx) = @_;
    $self->{gmpp}->x_to_lng($imx + $self->leftend);
}

sub imy_to_lat {
    my ($self, $imy) = @_;
    $self->{gmpp}->y_to_lat($imy + $self->topend);
}

sub range {
    my $self = shift;

    my @xrange = ($self->leftend, $self->leftend + $self->{width});
    my @yrange = ($self->topend,  $self->topend + $self->{height});

    (\@xrange, \@yrange);
}

sub range_latlng {
    my $self = shift;

    (
        [ $self->imy_to_lat(0), $self->imy_to_lat($self->{height}) ],
        [ $self->imx_to_lng(0), $self->imx_to_lng($self->{width})  ],
    );
}

sub range_tile {
    my $self = shift;

    my ($xrange, $yrange) = $self->range;

    my $gmpp = $self->{gmpp};
    (
        [ $gmpp->tileindexof($xrange->[0]), $gmpp->tileindexof($xrange->[1]) + 1 ],
        [ $gmpp->tileindexof($yrange->[0]), $gmpp->tileindexof($yrange->[1]) + 1 ],
    );
}

1;

package Geo::Map::PlanarProjection::Viewport;
use strict;
use warnings;
use Carp;

use Geo::Map::PlanarProjection;

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

    $self->{gmpp} = Geo::Map::PlanarProjection->new($self->{zoom});

    $self;
}

sub leftend {
    my $self = shift;
    $self->{gmpp}->lng2x($self->{clng}) - $self->{width} / 2;
}

sub topend {
    my $self = shift;
    $self->{gmpp}->lat2y($self->{clat}) - $self->{height} / 2;
}

sub imxoflng {
    my ($self, $lng) = @_;
    $self->{gmpp}->lng2x($lng) - $self->leftend;
}

sub imyoflat {
    my ($self, $lat) = @_;
    $self->{gmpp}->lat2y($lat) - $self->topend;
}

sub lngofimx {
    my ($self, $imx) = @_;
    $self->{gmpp}->x2lng($imx + $self->leftend);
}

sub latofimy {
    my ($self, $imy) = @_;
    $self->{gmpp}->y2lat($imy + $self->topend);
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
        [ $self->latofimy(0), $self->latofimy($self->{height}) ],
        [ $self->lngofimx(0), $self->lngofimx($self->{width})  ],
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

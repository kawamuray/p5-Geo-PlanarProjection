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
    $self->{pproj} ||= Geo::PlanarProjection->new($self->zoom);
}

sub lng_to_imx {
    my ($self, $lng) = @_;
    $self->pproj->lng_to_x($lng) - $self->leftend;
}

sub lat_to_imy {
    my ($self, $lat) = @_;
    $self->pproj->lat_to_y($lat) - $self->topend;
}

sub imx_to_lng {
    my ($self, $imx) = @_;
    $self->pproj->x_to_lng($imx + $self->leftend);
}

sub imy_to_lat {
    my ($self, $imy) = @_;
    $self->pproj->y_to_lat($imy + $self->topend);
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
        [ $self->imy_to_lat(0), $self->imy_to_lat($self->height) ],
        [ $self->imx_to_lng(0), $self->imx_to_lng($self->width)  ],
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

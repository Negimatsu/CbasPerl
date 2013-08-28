package SVG::Graph::Glyph::bar;
BEGIN {
  $SVG::Graph::Glyph::bar::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use base SVG::Graph::Glyph;
use strict;
use Data::Dumper;

our @lifts;


sub draw {
    my ( $self, @args ) = @_;

    my ( $x1, $x2, $y1, $y2 ) = ( undef, undef, undef, undef );

    #this will be the width of a bar, we need to calculate the
    #minimum distance between any two values in the data,
    #and use that as the step size.
    my $step = undef;
    my %xcoords = map { $_->x => 1 } $self->group->data;

    ( $x1, $x2 ) = ( undef, undef );
    foreach my $xcoord ( sort { $a <=> $b } keys %xcoords ) {

        $x1 = $xcoord and next unless defined($x1);
        $x2 = $xcoord;

        if ( !defined($step) ) {
            $step = $x2 - $x1;
        }
        else {
            $step = $x2 - $x1 < $step ? $x2 - $x1 : $step;
        }

        $x1 = $x2;
    }

    if ( $self->group->stack ) {
        foreach my $data ( $self->group->data_chunks ) {
            my @newlifts = $self->_bars( $step, \@lifts, [ $data->data ] );
            my $i = 0;
            foreach my $newlift (@newlifts) {
                $lifts[$i] += $newlift;
                $i++;
            }
        }
    }
    else {
        $self->_bars( $step, \@lifts, [ $self->group->data ] );
    }
}

sub _bars {
    my $self = shift;
    my ( $step, $lifts, $data ) = @_;

    my @ls = ();
    my $l;

    #FIXME this logic is fubar, but it keeps things in proper scale.
    my $yscale;
    if ( $self->group->stack ) {
        $yscale = $self->ysize / ( $self->group->_parent_group->ymax );
    }
    else {
        $yscale = $self->yscale;
    }

    #AD: umm... why?
    #xscale is ++'d for fencepost error
    my $w = ( $self->xsize - ( $step * ( $self->xscale ) ) )
        / ( $self->group->xrange );    #+1

    my $lift;

    my ( $x1, $x2, $y1, $y2 ) = (
        ( ( $self->group->xmin - $self->group->xmin ) * ( $self->xscale ) )
        + $self->xoffset,              #+1
        undef,
        (   $self->ysize
                - ( $self->group->ymin - $self->group->ymin ) * $yscale
            ) + $self->yoffset,
        undef,
    );

    foreach my $datum ( sort { $a->x <=> $b->x } @$data ) {

        $lift = shift @$lifts;
        push @ls, ( $self->ysize - $y1 + $self->yoffset ) + $lift;

        if ( !defined($x1) and !defined($y1) ) {
            $x1 = ( ( $datum->x - $self->group->xmin ) * $w )
                + $self->xoffset;
            $y1
                = (
                $self->ysize - ( $datum->y - $self->group->ymin ) * $yscale )
                + $self->yoffset;
            next;
        }

        $x2 = ( ( $datum->x - $self->group->xmin ) * $w ) + $self->xoffset;
        $y2 = ( $self->ysize - ( $datum->y - $self->group->ymin ) * $yscale )
            + $self->yoffset;

        $self->canvas->rectangle(
            x      => $x1,
            y      => $y1 - $lift,
            width  => $w,
            height => $self->ysize - $y1 + $self->yoffset,
            style  => { $self->_style }
        );

        $x1 = $x2;
        $y1 = $y2;
    }

    $lift = shift @$lifts;
    push @ls, ( $self->ysize - $y1 + $self->yoffset ) + $lift;

    #plot the last data bar
    $self->canvas->rectangle(
        x      => $x1,
        y      => $y1 - $lift,
        width  => $w,
        height => $self->ysize - $y1 + $self->yoffset,
        style  => { $self->_style }
    );

    return @ls;
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Glyph::bar

=head2 draw

 Title   : draw
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head1 AUTHOR

Chris Fields <cjfields@bioperl.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Chris Fields.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


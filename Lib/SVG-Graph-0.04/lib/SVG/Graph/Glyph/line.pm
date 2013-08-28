package SVG::Graph::Glyph::line;
BEGIN {
  $SVG::Graph::Glyph::line::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use base SVG::Graph::Glyph;
use strict;


sub draw {
    my ( $self, @args ) = @_;

    my $id = 'n' . sprintf( "%07d", int( rand(9999999) ) );
    my $group = $self->svg->group( id => "line$id" );

    my $xscale = $self->xsize / $self->group->xrange;
    my $yscale = $self->ysize / $self->group->yrange;

    my ( $x1, $x2, $y1, $y2 );
    foreach my $datum ( sort { $a->x <=> $b->x } $self->group->data ) {
        if ( !defined($x1) and !defined($y1) ) {
            $x1 = ( ( $datum->x - $self->group->xmin ) * $xscale )
                + $self->xoffset;
            $y1
                = (
                $self->ysize - ( $datum->y - $self->group->ymin ) * $yscale )
                + $self->yoffset;
            next;
        }

        $x2 = ( ( $datum->x - $self->group->xmin ) * $xscale )
            + $self->xoffset;
        $y2 = ( $self->ysize - ( $datum->y - $self->group->ymin ) * $yscale )
            + $self->yoffset;

        $group->line(
            x1    => $x1,
            y1    => $y1,
            x2    => $x2,
            y2    => $y2,
            style => { $self->_style }
        );

        $x1 = $x2;
        $y1 = $y2;
    }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Glyph::line

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


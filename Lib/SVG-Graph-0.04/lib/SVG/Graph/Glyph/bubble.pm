package SVG::Graph::Glyph::bubble;
BEGIN {
  $SVG::Graph::Glyph::bubble::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use base SVG::Graph::Glyph;
use strict;


sub draw {
    my ( $self, @args ) = @_;

    my $id = 'n' . sprintf( "%07d", int( rand(9999999) ) );
    my $group = $self->svg->group( id => "bubble$id" );

    my $xscale = $self->xsize / $self->group->xrange;
    my $yscale = $self->ysize / $self->group->yrange;
    my $zscale = 30 / $self->group->zrange;

    foreach my $datum ( $self->group->data ) {
        my $cx = ( ( $datum->x - $self->group->xmin ) * $xscale )
            + $self->xoffset;
        my $cy
            = (
            ( $self->xsize - ( $datum->y - $self->group->ymin ) * $yscale ) )
            + $self->yoffset;

        my $r = $zscale * ( $datum->z + 0.001 );

        $group->circle(
            cx    => $cx,
            cy    => $cy,
            r     => $r,
            style => { $self->_style }
        );
    }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Glyph::bubble

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


package SVG::Graph::Glyph::scatter;
BEGIN {
  $SVG::Graph::Glyph::scatter::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use base SVG::Graph::Glyph;
use strict;


sub draw {
    my ( $self, @args ) = @_;

    my $id = 'n' . sprintf( "%07d", int( rand(9999999) ) );
    my $group = $self->svg->group( id => "scatter$id" );

    foreach my $datum ( $self->group->data ) {
        my $cx = ( ( $datum->x - $self->group->xmin ) * $self->xscale )
            + $self->xoffset;
        my $cy = (
            (   $self->xsize
                    - ( $datum->y - $self->group->ymin ) * $self->yscale
            )
        ) + $self->yoffset;

        $group->circle(
            cx    => $cx,
            cy    => $cy,
            r     => 3,
            style => { $self->_style }
        );
    }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Glyph::scatter

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


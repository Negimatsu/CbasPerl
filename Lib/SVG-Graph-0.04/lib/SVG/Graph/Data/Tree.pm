package SVG::Graph::Data::Tree;
BEGIN {
  $SVG::Graph::Data::Tree::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use strict;
use SVG::Graph::Data::Node;


sub new {
    my ( $class, @args ) = @_;
    my $self = bless {}, $class;
    $self->init(@args);
    return $self;
}


sub init {
    my ( $self, %args ) = @_;

    $self->root( SVG::Graph::Data::Node->new );
    $self->root->name('root');

    foreach my $arg ( keys %args ) {
        $self->$arg( $args{$arg} );
    }
}


sub depth {
    my ( $self, @args ) = @_;

    return $self->root->depth;
}


sub root {
    my $self = shift;

    return $self->{'root'} = shift if @_;
    return $self->{'root'};
}


sub new_node {
    my ( $self, @args ) = @_;

    return SVG::Graph::Data::Node->new(@args);
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Data::Tree

=head2 new

 Title   : new
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 init

 Title   : init
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 depth

 Title   : depth
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 root

 Title   : root
 Usage   : $obj->root($newval)
 Function:
 Example :
 Returns : value of root (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=head2 new_node

 Title   : new_node
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


package SVG::Graph::Data::Node;
BEGIN {
  $SVG::Graph::Data::Node::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use strict;
use base qw(Tree::DAG_Node);


sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;
    $self->init(%args);
    return $self;
}


sub init {
    my ( $self, %args ) = @_;

    $self->SUPER::_init;

    foreach my $arg ( keys %args ) {
        my $meth = $arg;
        if ( $self->can($meth) ) {
            $self->$meth( $args{$arg} );
        }
        else {
            $self->_style( $arg => $args{$arg} );
        }
    }

}


sub depth {
    my ( $self, @args ) = @_;

    my $depth = $self->branch_length;

    my $maxdepth = 0;
    foreach my $daughter ( $self->daughters ) {
        my $ddepth = $daughter->depth;
        $maxdepth = $ddepth > $maxdepth ? $ddepth : $maxdepth;
    }

    return $depth + $maxdepth;
}


sub branch_length {
    my $self = shift;

    return $self->{'branch_length'} = shift if @_;
    return $self->{'branch_length'} || 1;
}


sub branch_type {
    my $self = shift;

    return $self->{'branch_type'} = shift if @_;
    return $self->{'branch_type'};
}


sub branch_label {
    my $self = shift;

    return $self->{'branch_label'} = shift if @_;
    return $self->{'branch_label'} || '';
}


sub _style {
    my $self = shift;
    my ( $key, $val ) = @_;

    if ( defined($key) and not defined($val) ) {
        return $self->{'_style'}{$key};
    }
    elsif ( defined($key) and defined($val) ) {
        $self->{'_style'}{$key} = $val;
        return $val;
    }
    else {
        return $self->{'_style'} ? %{ $self->{'_style'} } : ();
    }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Data::Node

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

=head2 branch_length

 Title   : branch_length
 Usage   : $obj->branch_length($newval)
 Function:
 Example :
 Returns : value of branch_length (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=head2 branch_type

 Title   : branch_type
 Usage   : $obj->branch_type($newval)
 Function:
 Example :
 Returns : value of branch_type (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=head2 branch_label

 Title   : branch_label
 Usage   : $obj->branch_label($newval)
 Function:
 Example :
 Returns : value of branch_label (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=head2 _style

 Title   : _style
 Usage   : $obj->_style($newval)
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


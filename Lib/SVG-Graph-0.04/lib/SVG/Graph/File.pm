package SVG::Graph::File;
BEGIN {
  $SVG::Graph::File::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use strict;


sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;
    $self->init(%args);
    return ($self);
}


sub init {
    my ( $self, %args ) = @_;
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


sub read_data {
    my ( $self, @args ) = @_;

    die "method undefined by " . __PACKAGE__;
}


sub write_data {
    my ( $self, @args ) = @_;

    die "method undefined by " . __PACKAGE__;
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

SVG::Graph::File

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

=head2 read_data

 Title   : read_data
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 write_data

 Title   : write_data
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

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


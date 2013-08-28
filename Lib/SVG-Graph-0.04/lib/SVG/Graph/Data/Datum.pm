package SVG::Graph::Data::Datum;
BEGIN {
  $SVG::Graph::Data::Datum::AUTHORITY = 'cpan:CJFIELDS';
}

our $VERSION = '0.04'; # VERSION

use strict;

#use overload
#  '""'  => \&label,
#  '<=>' => sub { my($x,$y) = &check; $x <=> $y },
#  '+'   => sub { my($x,$y) = &check; $x+$y     },
#  '-'   => sub { my($x,$y) = &check; $x-$y     },
#  '*'   => sub { my($x,$y) = &check; $x*$y     },
#  '/'   => sub { my($x,$y) = &check; $x/$y     },
#  ;


sub new {
    my ( $class, %args ) = @_;
    my $self = bless {}, $class;
    $self->init(%args);
    return $self;
}


sub init {
    my ( $self, %args ) = @_;
    foreach my $arg ( keys %args ) {
        $self->$arg( $args{$arg} );
    }
}


sub x {
    my ( $self, $arg ) = @_;
    $self->{x} = $arg if defined $arg;
    return $self->{x};
}


sub y {
    my ( $self, $arg ) = @_;
    $self->{y} = $arg if defined $arg;
    return $self->{y};
}


sub z {
    my ( $self, $arg ) = @_;
    $self->{z} = $arg if defined $arg;
    return $self->{z};
}


sub label {
    my ( $self, $arg ) = @_;
    $self->{label} = $arg if defined $arg;
    return $self->{label};
}


sub check {
    my ( $x, $y ) = @_;

    $x = $x->x if ref $x eq __PACKAGE__;
    $y = $y->x if ref $y eq __PACKAGE__;

    return ( $x, $y );
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

SVG::Graph::Data::Datum

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

=head2 x

 Title   : x
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 y

 Title   : y
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 z

 Title   : z
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 label

 Title   : label
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=head2 check

 Title   : check
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


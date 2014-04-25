package CheckFileFasta;

use warnings;
use Bio::Seq;
use Bio::SeqIO;

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName   => $arg{inputName}   || "no input filename",
        _pathName    => $arg{pathName}    || "No path name"
    }, $class;
    return $self;
}

sub get_inputName   { $_[0]->{_inputName} }
sub get_pathName    { $_[0]->{_pathName} }

sub set_inputName {
    my ( $self, $inputName ) = @_;
    $self->{_inputName} = $inputName if $inputName;
}

sub set_pathName {
    my ( $self, $pathName ) = @_;
    $self->{_pathName} = $pathName if $pathName;
}
package Percentfile;
use Time::Piece;
use warnings;
use strict;


sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName      => $arg{inputName}  || "Percentfile.txt",
        _pathName 		=> $arg{pathName}  ,
        }, $class;
    return $self;
}

sub get_inputName    { $_[0]->{_inputName} }
sub get_pahtName    { $_[0]->{_pathName} }


sub set_inputName {
    my ( $self, $inputName ) = @_;
    $self->{_inputName} = $inputName if $inputName;
}

sub set_pathName {
    my ( $self, $pathName ) = @_;
    $self->{_pahtName} = $pathName if $pathName;
}


sub open_file{
	my $filename = $_[0]->{_inputName};
	my $pathname = $_[0]->{_pathName};
	my $Dfile = $pathname.$filename;
	open FILE, ">$Dfile" or die $!;
	print FILE "init\n";
	close FILE;
}

sub add_word{
	my $word = $_[1];
	my $percent = $_[2];
	my $filename = $_[0]->{_inputName};
	my $pathname = $_[0]->{_pathName};
	my $Dfile = $pathname.$filename;

	open FILE, ">>$Dfile" or die $!;
	print FILE "$word|$percent|" ,localtime->strftime('%Y-%m-%d %H:%M:%S'),"\n";
	close FILE;
}

sub add_done{
	my $filename = $_[0]->{_inputName};
	my $pathname = $_[0]->{_pathName};
	my $Dfile = $pathname.$filename;

	open FILE, ">>$Dfile" or die $!;
	print FILE "done!|100|" ,localtime->strftime('%Y-%m-%d %H:%M:%S'),"\n";
	close FILE;



}

1;


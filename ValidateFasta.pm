package ValidateFasta;

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


sub check_file{
    my $filename = $_[0]->{_inputName};
    my $pathname = $_[0]->{_pathName};
    my $pathfile = $pathname.$filename;
    my $flag = 'true';

    my $seq_in  = Bio::SeqIO->new(
                              -format => 'fasta',
                              -file   => $pathfile,
                              );
    
    while( my $seq = $seq_in->next_seq() ){
        unless ( is_valid_syntax($seq->display_id) eq 'true'){
            $flag = 'false';
            print STDERR "Sequence at is not right format ".$seq->display_id."\n";
        }
        
    }
    
    if ( $flag eq 'false'){
        return 'false';
    }elsif( $flag eq 'true'){
        return 'true';
    }

}

sub is_valid_syntax{
    my $display_id = $_[0];
    my @names = split /-/, $display_id;
    if ( $names[-1] =~ /^\d+$/ and $names[-2] =~/[[:alpha:]]/){
        return 'true';
    }else{
        return 'false';
    }

}
1;

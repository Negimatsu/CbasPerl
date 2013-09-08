package AssignUnknown;

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use Unknown;

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName 			=> $arg{inputName} || "no input filename",
        _pathName  			=> $arg{pathName}  || "No path name",
        _fileAssignUnknown 	=> "asgUnknown.fasta",
        _fielOuputCombine	=> "MlstFile.fasta"
    }, $class;
    return $self;
}

sub get_inputName			{ $_[0] -> {_inputName}			}
sub get_pathName			{ $_[0] -> {_pathName}			}
sub get_fileAssignUnknown	{ $_[0] -> {_fileAssignUnknown}	}
sub get_fileOuputCombine	{ $_[0] -> {_fielOuputCombine}	}

sub set_inputCombine {
	my ($self, $inputCombine) = @_;
	$self -> {_inputCombine} = $inputCombine if $inputCombine;
	}

sub set_pathName {
	my ($self, $pathName) = @_;
	$self -> {_pathName} = $pathName if $pathName;
	}
	
sub set_fileAssignUnknown {
	my ($self, $fileAssignUnknown) = @_;
	$self -> {_fileAssignUnknown} = $fileAssignUnknown if $fileAssignUnknown;
	}

sub set_fielOuputCombine {
	my ($self, $fielOuputCombine) = @_;
	$self -> {_fielOuputCombine} = $fielOuputCombine if $fielOuputCombine;
	}

sub createUnknown{
	my $inputFile 	= $_[0] -> {_inputName};
	my $pathName 	= $_[0] -> {_pathName};
	my $fileOutput 	= $_[0] -> {_fileAssignUnknown};	
	my $DFile     	= $pathName.$inputFile;

    my $seqio    = Bio::SeqIO->new(
        -format => 'fasta',
        -file   => $DFile  );

    my $seqio_output = Bio::SeqIO->new(
        -file   => '>' . $pathName . '/'.$fileOutput,
        -format => 'fasta' );

    my $unknown = Unknown->new;

    while ( my $pseq = $seqio->next_seq() ) {

        #initial for search mlst database.
        my @speNames = split /\|/, $pseq->desc;
        my @display_id  = split /-/, $pseq->display_id;
        my $alleleName 	= $display_id[0];
        my $sequence 	= $pseq->seq();

        print "$alleleName and \n$sequence\n";
        my $assignAllele = $unknown->getNameAllele($alleleName,$sequence);

        print "$assignAllele\n";

        my $assignFasta = "$assignAllele|DB Unknown";

        my $seq_obj = Bio::Seq->new(
            -seq        => $pseq->seq(),
            -display_id => $pseq->display_id,
            -desc       => $pseq->desc . "|" . $assignFasta,
            -alphabet   => "dna"
        );

        $seqio_output->write_seq($seq_obj);
    }
}

sub compoundFile{

	my $inputFileKnown = $_[1];
	my $pathName 	= $_[0] -> {_pathName};
	my $fileUnknown	= $_[0] -> {_fileAssignUnknown};
	my $fileOuput 	= $_[0] -> {_fielOuputCombine};	
	my $DKnonwn     = $pathName.$inputFileKnown;
	my $DUnKnown	= $pathName.$fileUnknown;

	my $seqKnown    = Bio::SeqIO->new(
        -format => 'fasta',
        -file   => $DKnonwn  );

	my $seqUnknow	= Bio::SeqIO->new(
        -format => 'fasta',
        -file   => $DUnKnown  );

    my $seqio_output = Bio::SeqIO->new(
        -file   => ">$pathName/$fileOuput",
        -format => 'fasta' );

    while ( my $pseq = $seqKnown->next_seq() ) {

        my $seq_obj = Bio::Seq->new(
            -seq        => $pseq->seq(),
            -display_id => $pseq->display_id,
            -desc       => $pseq->desc ,
            -alphabet   => "dna"
        );

        $seqio_output->write_seq($seq_obj);
    }

    while ( my $pseq = $seqUnknow->next_seq() ) {

        my $seq_obj = Bio::Seq->new(
            -seq        => $pseq->seq(),
            -display_id => $pseq->display_id,
            -desc       => $pseq->desc ,
            -alphabet   => "dna"
        );

        $seqio_output->write_seq($seq_obj);
    }
}


1;


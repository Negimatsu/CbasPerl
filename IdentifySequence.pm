package IdentifySequence;

use warnings;
use strict;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use Bio::Tools::Run::RemoteBlast;

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName   => $arg{inputName}   || "no input filename",
        _pathName    => $arg{pathName}    || "No path name",
        _db          => $arg{db}          || "Complete Genomes",
        _e_val       => $arg{e_val}       || "1e-10",
        _method      => $arg{method}      || "BLAST",
        _program     => $arg{program}     || "blastn",
        _percentIden => $arg{percentIden} || 75,
        _outputSpeciesfile  => "annotateSpecies.fasta"
    }, $class;
    return $self;
}

sub get_inputName   { $_[0]->{_inputName} }
sub get_pathName    { $_[0]->{_pathName} }
sub get_db          { $_[0]->{_db} }
sub get_e_val       { $_[0]->{_e_val} }
sub get_method      { $_[0]->{_method} }
sub get_program     { $_[0]->{_program} }
sub get_percentIden { $_[0]->{_percentIden} }
sub get_outputSpeciesfile { $_[0]->{_outputSpeciesfile} }

sub set_inputName {
    my ( $self, $inputName ) = @_;
    $self->{_inputName} = $inputName if $inputName;
}

sub set_pathName {
    my ( $self, $pathName ) = @_;
    $self->{_pathName} = $pathName if $pathName;
}

sub set_db {
    my ( $self, $db ) = @_;
    $self->{_db} = $db if $db;
}

sub set_e_val {
    my ( $self, $e_val ) = @_;
    $self->{_e_val} = $e_val if $e_val;
}

sub set_method {
    my ( $self, $method ) = @_;
    $self->{_method} = $method if $method;
}

sub set_program {
    my ( $self, $program ) = @_;
    $self->{_program} = $program if $program;
}

sub set_percentIden {
    my ( $self, $percentIden ) = @_;
    $self->{_percentIden} = $percentIden if $percentIden;
}

sub set_outputSpeciesfile {
    my ( $self, $outputSpeciesfile ) = @_;
    $self->{_outputSpeciesfile} = $outputSpeciesfile if $outputSpeciesfile;
}


#######################################
##This method use for search in blast program form use input
#######################################
sub SearchBlast {
    my $inputName = $_[0]->{_inputName};
    my $pathName  = $_[0]->{_pathName};
    my $fullName  = $pathName . $inputName;
    my $prog      = $_[0]->{_program};
    my $db        = $_[0]->{_db};
    my $e_val     = $_[0]->{_e_val};
    my $method    = $_[0]->{_method};
    my @params    = (
        '-prog'       => $prog,
        '-expect'     => $e_val,
        '-readmethod' => $method
    );

    my $factory = Bio::Tools::Run::RemoteBlast->new(@params);

    #$v is just to turn on and off the messages
    my $v = 1;

    my $str = Bio::SeqIO->new( -file => $fullName, -format => 'fasta' );
    while ( my $input = $str->next_seq() ) {

        #Blast a sequence against a database:

        #Alternatively, you could  pass in a file with many
        #sequences rather than loop through sequence one at a time
        #Remove the loop starting 'while (my $input = $str->next_seq())'
        #and swap the two lines below for an example of that.
        my $r = $factory->submit_blast($input);

        print STDERR "waiting..." if ( $v > 0 );
        while ( my @rids = $factory->each_rid ) {
            foreach my $rid (@rids) {
                my $rc = $factory->retrieve_blast($rid);
                if ( !ref($rc) ) {
                    if ( $rc < 0 ) {
                        $factory->remove_rid($rid);
                    }
                    print STDERR "." if ( $v > 0 );
                    sleep 5;

                } else {
                    my $result = $rc->next_result();

                    #save the output
                    my $filename = $result->query_name() . "\.bls";
                    $factory->save_output($pathName . 'conBlast/' . $filename );
                    $factory->remove_rid($rid);
                    
                    print "\nQuery Name : ", $result->query_name(), "\n";

                    while ( my $hit = $result->next_hit ) {
                        print $hit->description;
                        next unless ( $v > 0 );
                        print "\thit name is ", $hit->name, "\n";

                        while ( my $hsp = $hit->next_hsp ) {
                            if ( $hsp->percent_identity >= 75 ) {
                                print "\t\tscore is ", $hsp->score, "\n";
                            }
                        }
                    }
                }
            }
        }
        my $CheckFilename = $pathName . 'conBlast/' . $input->display_id . '.bls';
        if ( -e $CheckFilename ) {
            # print "File  $CheckFilename have";
        }
        else {
            print "File  $CheckFilename Exits redo";
            redo;
        }

    }

    # This example shows how to change a CGI parameter:
    $Bio::Tools::Run::RemoteBlast::HEADER{'MATRIX_NAME'} = 'BLOSUM45';
    $Bio::Tools::Run::RemoteBlast::HEADER{'GAPCOSTS'}    = '15 2';

    # And this is how to delete a CGI parameter:
    delete $Bio::Tools::Run::RemoteBlast::HEADER{'FILTER'};

}



###############################
#function Annotate file from blast's file.
#argument 1 is inputfile
#argument 2 is pathName
#argument 3 is percent identity from use
#return file Anno<filename>.fasta
###############################
sub Annotate {

    my $inputFile       = $_[0]->{_inputName};
    my $pathName        = $_[0]->{_pathName};
    my $outputFile      = $pathName . $inputFile;
    my $percentIdentity = $_[0]->{_percentIden};
    my $filnameeout     = $_[0]->{_outputSpeciesfile};
    my $anntateFileout  = $pathName.$filnameeout;

    my @namefile = split /\./, $inputFile;
    my $inSeq    = $namefile[0];
    my $seqio    = new Bio::SeqIO(
        -format => 'fasta',
        -file   => "$outputFile"
    );

    print $seqio->file;

    my $seqio_output = Bio::SeqIO->new(
        -file   => ">$anntateFileout",
        -format => 'fasta'
    );

    #Read blast file for annotation to fasta file.
    while ( my $pseq = $seqio->next_seq() ) {
        print "read filename" . $seqio->file . " displayId is ",
            $pseq->display_id;

        #Open File Blast from search
        my $in = new Bio::SearchIO(
            -format => 'blast',
            -file   => $pathName . '/conBlast/' . $pseq->display_id . '.bls'
        );

        my $result = $in->next_result;
        my $hit    = $result->next_hit;
        my $hsp    = $hit->next_hsp;

        if ( $hsp->length('total') > 50 ) {
            if ( $hsp->percent_identity >= $percentIdentity ) {
                print "Query=", $result->query_name,
                    " Hit=",        $hit->name,
                    " Length=",     $hsp->length('total'),
                    " Percent_id=", $hsp->percent_identity,
                    " des=",        $hit->description, "\n";

                my @speci = split /,/, $hit->description . "";
                my $species = $speci[0];

              #make annotate sequence file fasta one sequence in seqio_output.
                my $seq_obj = Bio::Seq->new(
                    -seq        => $pseq->seq(),
                    -display_id => $pseq->display_id,
                    -desc       => $hit->name . $species,
                    -alphabet   => "dna"
                );
                $seqio_output->write_seq($seq_obj);
            }
        }
    }
}

1;

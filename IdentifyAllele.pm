package IdentifyAllele;

#Written by Keith Jolley
#Implement by Ong krab
#use lib "/home/ongkrab/perl5/lib/perl5";

use SOAP::Lite;
use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName  => $arg{inputName}  || "no input filename",
        _pathName   => $arg{pathName}   || "No path name",
        _dblistName => $arg{dblistName} || "DBMlstUse.txt",
        _seqio_output => "",
        _fileDBname   => $arg{fileDBname} || ""
    }, $class;
    return $self;
}

sub get_inputName    { $_[0]->{_inputName} }
sub get_pathName     { $_[0]->{_pathName} }
sub get_dblistName   { $_[0]->{_dblistName} }
sub get_seqIO_output { $_[0]->{_seqIO_output} }
sub get_fileDBname   { $_[0]->{_fileDBname} }

sub set_inputName {
    my ( $self, $inputName ) = @_;
    $self->{_inputName} = $inputName if $inputName;
}

sub set_pathName {
    my ( $self, $pathName ) = @_;
    $self->{_pathName} = $pathName if $pathName;
}

sub set_dblistName {
    my ( $self, $dblistName ) = @_;
    $self->{_dblistName} = $dblistName if $dblistName;
}

sub set_seqIO_output {
    my ( $self, $seqIO_output ) = @_;
    $self->{_seqIO_output} = $seqIO_output if $seqIO_output;
}

sub set_fileDBname {
    my ( $self, $fileDBname ) = @_;
    $self->{_fileDBname} = $fileDBname if $fileDBname;
}

#####Sample arguments#########
my %DBnamesHashB;
my $database = 'bcc';
my $sequence = 'GCTTGGTAGTAGTCCACTAATGGTTTCGTGGTGGAGTGATACACTTTTAAGCGATCTAAT
ACAGTTTCCGGTTTATCATCGGCACGGATGATTAAGTCTTCGCCAGTCACGTCATCTTTC
CCTTCTACTTTTGGTGGGTTGTAAACGACGTGATAAGTACGACCTGAGGCTTGGTGTACA
CGGCGACCACTCATACGTTCTACGATCACTTCATCAGGCACATCAAACTCTAAAACGTAG
TCAATTTGGATACCGACTGTTTTTAATGCATCGGCTTGTGGGATAGTGCGTGGGAAGCCG
TCTAATAAGAAACCTTTGGCACAATCGGCTTGAGCAACACGTTCTTTCACTAATGAAATG
ATTAAATCATCTGGCACTAATTGACCCGCATCCATTAAGGTTTTTGCTTGTTTACCTAAG
TCTGTCCCTGCTTTGATTGCACCACGCAACATATCACCCGTTGAAA';
my $header
    = "Pasteurella multocida subsp. multocida str. HN06, complete genome";

my $numresults = 3;
##############################
sub searchInMLST {
##############~~~~~~~~~~~~~Main function~~~~~~~~~~~##################
    #filename is $inputFile.
    my $inputFile = $_[0]->{_inputName};
    my $pathName  = $_[0]->{_pathName};
    my $DFile     = $pathName . $inputFile;

    my @namefile = split /\./, $inputFile;
    my $inSeq    = $namefile[0];
    my $seqio    = Bio::SeqIO->new(
        -format => 'fasta',
        -file   => $DFile
    );
    print $seqio->file;

    my $seqio_output = Bio::SeqIO->new(
        -file   => '>' . $pathName . '/Mlst' . $inSeq . '.fasta',
        -format => 'fasta'
    );

    while ( my $pseq = $seqio->next_seq() ) {

        #initial for search mlst database.
        my @speNames = split /\|/, $pseq->desc;
        $header   = $speNames[2];
        $sequence = $pseq->seq();

        #Connect Mlst Database.
        #for search name database from species name
        my $NameDB = findNameDB($header);
        print "I will use database name is $NameDB\n";

        #get DB mlst name  and name profile
        my ( $nameFrMlst, $DBname ) = connectMlst( $NameDB, $sequence, );
        my $AnnoMlst
            = $nameFrMlst->{'locus'} . "-"
            . $nameFrMlst->{'id'}
            . "|DB $DBname ";
        print "Name for annotate " . $AnnoMlst . "\n";

        #Write file to Mlst<filename>.fasta
        my $seq_obj = Bio::Seq->new(
            -seq        => $pseq->seq(),
            -display_id => $pseq->display_id,
            -desc       => $pseq->desc . "|" . $AnnoMlst,
            -alphabet   => "dna"
        );
        $seqio_output->write_seq($seq_obj);
    }
}
##########~~~~~~~~~~~~~Main function~~~~~~~~~~~############

###function findNameDb is will be return DB name argument is header fasta file.
sub findNameDB {

    #get DB name from file DBMlstUse.txt
    open( INFO, "DBMlstUse.txt" ) or die("Could not open  file.");
    my %DBspeciHashB;
    my @DBnames;
    my $count = 0;
    foreach my $line (<INFO>) {
        my @liness = split /,/, $line;

        #print $liness[0]."\n";
        # print $line;
        $DBnamesHashB{ $liness[0] } = $liness[1];
        $DBspeciHashB{ $liness[1] } = $liness[0];
        push( @DBnames, $liness[0] );

        # if ($++counter == 2){
        # last;
        # }
    }
    close(INFO);

    ##############################
    my $check = $_[0];
    my @nick = split / /, $check;

    print "$nick[0]\n";

    #Search Name DB from descripttion name blast;
    my $useSPname = "";
    my $pickName  = "";
    foreach my $SPname ( values %DBnamesHashB ) {
        my @splitName = split / /, $SPname;
        if ( $splitName[0] eq $nick[0] ) {
            print "\n$splitName[0] and $nick[0]\n";
            if ( $splitName[1] eq $nick[1] ) {
                $useSPname = $DBspeciHashB{$SPname};
                print "database name ", $useSPname, "\n";
                last;
            }
            elsif ( $splitName[1] == "spp." ) {
                $pickName = $DBspeciHashB{$SPname};
                print $pickName;
                next;
            }
        }
    }

    ###Choose Name if not sp. but it's have spp. I will choose.

    my $DBnameUseSearch = "";

    if ( ( $useSPname ne '' ) ) {
        $DBnameUseSearch = $useSPname;
    }
    elsif ( $pickName ne "" ) {
        $DBnameUseSearch = $pickName;
    }

    #print "use database name". $DBnameUseSearch;

    return $DBnameUseSearch;
}

###############################

#function Search from DB Mlst.
#argument 1 is name DB
#argument 2 is name Sequence for search
###############################

sub connectMlst {
    my $searchDBname  = $_[0];
    my $sequnceSearch = $_[1];
    my $locus         = $_[2];
    my $soap          = SOAP::Lite->uri('http://pubmlst.org/MLST')
        ->proxy('http://pubmlst.org/cgi-bin/mlstdbnet/mlstFetch.pl');

    my $nameFromMlst;
    my $database = $searchDBname;

    if ( !$database ) {
        foreach my $DBname ( keys my %DBnamesHashB ) {
            $sequnceSearch = $DBname;
            my $soapResponse
                = $soap->blast( $database, $sequnceSearch, $numresults );
            unless ( $soapResponse->fault ) {
                for my $t ( $soapResponse->valueof('//blastMatch') ) {
                    print $t->{'locus'} . "-"
                        . $t->{'id'}
                        . ': Mismatches:'
                        . $t->{'mismatches'}
                        . '; Gaps:'
                        . $t->{'gaps'}
                        . '; Alignment '
                        . $t->{'alignment'} . '/'
                        . $t->{'length'}
                        . "on  database name $database\n";
                    $nameFromMlst = $t;
                    last;
                }
                if ( !$soapResponse->valueof('//blastMatch') ) {
                    $nameFromMlst = "Unknown";
                    print "This $database not found \n";
                    next;
                }
            }
            else {
                print join ', ', $soapResponse->faultcode,
                    $soapResponse->faultstring;
            }
        }
    }
    else {
        my $soapResponse
            = $soap->blast( $database, $sequnceSearch, $numresults );
        unless ( $soapResponse->fault ) {
            for my $t ( $soapResponse->valueof('//blastMatch') ) {
                print $t->{'locus'} . "-"
                    . $t->{'id'}
                    . ': Mismatches:'
                    . $t->{'mismatches'}
                    . '; Gaps:'
                    . $t->{'gaps'}
                    . '; Alignment '
                    . $t->{'alignment'} . '/'
                    . $t->{'length'}
                    . "on  database name $database\n";
                $nameFromMlst = $t;
                last;
            }
            if ( !$soapResponse->valueof('//blastMatch') ) {
                $nameFromMlst = "Unknown";
                print "This $database not found \n";
                next;
            }
        }
        else {
            print join ', ', $soapResponse->faultcode,
                $soapResponse->faultstring;
        }
    }

    return $nameFromMlst, $database;
}
1;

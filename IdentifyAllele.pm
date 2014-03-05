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
use FindBin;
# no warnings 'uninitialized';

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName      => $arg{inputName}  || "no input filename",
        _pathName       => $arg{pathName}   || "No path name",
        _dblistName     => $arg{dblistName} || "DBMlstUse.txt",
        _file_output    => "knownMlst.fasta",
        _fileUnknown    => "unknown.fasta",
        _fileDBname     => $arg{fileDBname} || ""
    }, $class;
    return $self;
}

sub get_inputName    { $_[0]->{_inputName} }
sub get_pathName     { $_[0]->{_pathName} }
sub get_dblistName   { $_[0]->{_dblistName} }
sub get_file_output  { $_[0]->{_seqIO_output} }
sub get_fileDBname   { $_[0]->{_fileDBname} }
sub get_fileUnknown   { $_[0]->{_fileUnknown} }

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

sub set_file_output {
    my ( $self, $_file_output ) = @_;
    $self->{_file_output} = $_file_output if $_file_output;
}

sub set_fileDBname {
    my ( $self, $fileDBname ) = @_;
    $self->{_fileDBname} = $fileDBname if $fileDBname;
}

sub set_fileUnknown {
    my ( $self, $fileUnknown ) = @_;
    $self->{_fileUnknown} = $fileUnknown if $fileUnknown;
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
#####Sample arguments#########

###########################################################
#This method is main fucntion for search in mlst.
###########################################################
##############~~~~~~~~~~~~~Main function~~~~~~~~~~~##################
sub searchInMLST {

    #filename is $inputFile.
    my $inputFile = $_[0]->{_inputName};
    my $pathName  = $_[0]->{_pathName};
    my $DFile     = $pathName . $inputFile;
    my $fileOutput = $_[0]->{_file_output};
    my $fileUnknown = $_[0]->{_fileUnknown};

    my @namefile = split /\./, $inputFile;
    my $inSeq    = $namefile[0];
    my $seqio    = Bio::SeqIO->new(
        -format => 'fasta',
        -file   => $DFile
    );
    print $seqio->file;

    my $seqio_output = Bio::SeqIO->new(
        -file   => '>' . $pathName . "/$fileOutput",
        -format => 'fasta'
    );

    my $seqio_outputU = Bio::SeqIO->new(
                            -file   => '>' . $pathName . "/$fileUnknown",
                            -format => 'fasta' );

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
        my ( $nameFrMlst, $DBname ,$foundMLST) = connectMlst( $NameDB ,$pseq);
        
        unless($foundMLST eq "found"){ 

            my $seq_obj = Bio::Seq->new(
                            -seq        => $pseq->seq(),
                            -display_id => $pseq->display_id,
                            -desc       => $pseq->desc ,
                            -alphabet   => "dna");

            $seqio_outputU->write_seq($seq_obj);


        }else{
            my $AnnoMlst =  $nameFrMlst->{'locus'} . "-"
                            . $nameFrMlst->{'id'}
                            . "|DB $DBname ";
            print "Name for annotate " . $AnnoMlst . "\n";

        #Write file to Mlst<filename>.fasta
            my $seq_obj = Bio::Seq->new(
                -seq        => $pseq->seq(),
                -display_id => $pseq->display_id,
                -desc       => $pseq->desc . "|" . $AnnoMlst,
                -alphabet   => "dna" );
            $seqio_output->write_seq($seq_obj);
        }
    }
}
##########~~~~~~~~~~~~~Main function~~~~~~~~~~~############


###function findNameDb is will be return DB name argument is header fasta file.
sub findNameDB {

    #get DB name from file DBMlstUse.txt
    #open( INFO, '/home/ongkrab/MyProjectCbas/Deverlopment/codePerl/DBMlstUse.txt' ) or die("Could not open  file. $!");
    open( INFO, "$FindBin::Bin/DBMlstUse.txt" ) or die("Could not open  file. $!");
    my %DBspeciHashB;
    my @DBnames;
    my $count = 0;
    foreach my $line (<INFO>) {
        my @liness = split /,/, $line;

        $DBnamesHashB{ $liness[0] } = $liness[1];
        $DBspeciHashB{ $liness[1] } = $liness[0];
        #push( @DBnames, $liness[0] );

        # if ($++counter == 2){
        # last;
        # }
    }
    close(INFO);

    ##############################
    my $check = $_[0];
    # my @nick = split / /, $check;

    print "String is annotate $check\n";

    #Search Name DB from descripttion name blast;
    my $useSPname = "";
    my $pickName  = "";
    foreach my $SPname ( values %DBnamesHashB ) {
        # my @splitName = split / /, $SPname;
        # if ( $splitName[0] eq $nick[0] ) {
        #     print "\n$splitName[0] and $nick[0]\n";
        #     if ( $splitName[1] eq $nick[1] ) {
        #         $useSPname = $DBspeciHashB{$SPname};
        #         print "database name ", $useSPname, "\n";
        #         last;
        #     }
        #     elsif ( $splitName[1] == "spp." ) {
        #         $pickName = $DBspeciHashB{$SPname};
        #         print $pickName;
        #         next;
        #     }
        # }
        my $resultSearhName = index($check,$SPname) ;
        if ($resultSearhName >= 0 and $resultSearhName != -1 ){
            $useSPname = $DBspeciHashB{$SPname};
            print "Database name ", $useSPname, "\n";
            last;
        }
    }

    ###Choose Name if not sp. but it's have spp. I will choose.

    my $DBnameUseSearch = "";

    if ( ( $useSPname ne '' ) ) {
        $DBnameUseSearch = $useSPname;
    }
    # elsif ( $pickName ne "" ) {
    #     $DBnameUseSearch = $pickName;
    # }
    return $DBnameUseSearch;
}


###############################
#function Search from DB Mlst.
#argument 1 is name DB
#argument 2 is name Sequence for search
#argument 3 is locus ex adk ,gdh .
###############################
sub connectMlst {
    my $searchDBname  = $_[0];
    my $pseq        = $_[1];
    my @display_id  = split /-/, $pseq->display_id;
    my $locus = $display_id[0];
    my $sequnceSearch = $pseq->seq();
    my $found;

    my $nameAllelic;
    my $database = $searchDBname;

    if ( !$database ) {
        foreach my $DBname ( keys my %DBnamesHashB ) {
            $sequnceSearch = $DBname;
            ($nameAllelic,$found) = searchInPubMlstSOAP( $database, $sequnceSearch );
        }
    }
    else {

        ($nameAllelic,$found) = searchInPubMlstSOAP($database, $sequnceSearch);
    }
    return $nameAllelic, $database , $found;
}



###############################
#Implement from Keith Jolley
#connect with pubmlst database 
#argument 1 is name databasename in file DBmlstUse.txt Ex pmultocida_rirdc,Pasteurella multocida use pmultocida_rirdc
#argument 2 is name Sequence for search
#argument 3 is fasta sequence for file have unknown.
###############################
sub searchInPubMlstSOAP{
    my $databaseName   =   $_[0];
    my $sequenceSearch =   $_[1];
    my $pseq           =   $_[2];
    my $soap        = SOAP::Lite -> uri('http://pubmlst.org/MLST')
                                ->proxy('http://pubmlst.org/cgi-bin/mlstdbnet/mlstFetch.pl');
     
    #return variable
    my $nameFromMlst;
    my $foundMLST = "found";
    my $soapResponse = $soap->blast( $databaseName, $sequenceSearch, $numresults );
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
                    . "\non  database name $database\n";
            if( $t->{'mismatches'} != 0 || $t->{'gaps'} != 0 || $t->{'alignment'} != $t->{'length'} ){
                $foundMLST = "unfound";
                last;
            }else{
                $nameFromMlst = $t;    
                last;
            }         
            
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
    return $nameFromMlst,$foundMLST;
}

#######################################
##This method use for add unknown sequence to unknown file
##argument 1 is unknown sequence for fasta format
#######################################
sub addUnknown{
    my $pseq = $_[0];
    my $fileUnknown = $_[0]->{_fileUnknown};
    my $pathName  = $_[0]->{_pathName};

    my $DFile     = $pathName.$fileUnknown;#"../UserData/9/unknown.fasta";

    my $seqio_outputU = Bio::SeqIO->new(
            -file   => ">$DFile",
            -format => 'fasta' );

    my $seq_obj = Bio::Seq->new(
            -seq        => $pseq->seq(),
            -display_id => $pseq->display_id,
            -desc       => $pseq->desc ,
            -alphabet   => "dna");

    $seqio_outputU->write_seq($seq_obj);
}

1;

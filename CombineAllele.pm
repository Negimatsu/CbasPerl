package CombineAllele;

use List::Util qw(min max);
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use warnings;


#This method want to argument filein for filename input.
sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName => $arg{inputName} || "no input filename",
        _pathName  => $arg{pathName}  || "No path name",
        _tree      => $arg{tree}      || "DBMlstUse",
        _fileOutputCombine => "allelicProfile.txt",
        _fileOutputCombineBurst => "allelicProfileBurst.txt",
        _fileOutputCombineAllelicForUser => "AllelicProfileForUser.txt",
        _fileOutputErrorAllelic => "errorAllelic.txt"
    }, $class;

    return $self;
}

sub get_inputName         { $_[0]->{_inputName} }
sub get_pathName          { $_[0]->{_pathName} }
sub get_tree              { $_[0]->{_tree} }
sub get_fileOutputCombine { $_[0]->{_fileOutputCombine} }
sub get_fileOutputCombineBurst { $_[0]->{_fileOutputCombineBurst} }
sub get_fileOutputCombineAllelicForUser { $_[0]->{_fileOutputCombineAllelicForUser} }
sub get_fileOutputErrorAllelic { $_[0]->{_fileOutputErrorAllelic} }

sub set_inputName {
    my ( $self, $inputName ) = @_;
    $self->{_inputName} = $inputName if $inputName;
}

sub set_pathName {
    my ( $self, $pathName ) = @_;
    $self->{_pathName} = $pathName if $pathName;
}

sub set_tree {
    my ( $self, $tree ) = @_;
    $self->{_tree} = $tree if $tree;
}

sub set_fileOutputCombine {
    my ( $self, $fileOutputCombine ) = @_;
    $self->{_fileOutputCombine} = $fileOutputCombine if $fileOutputCombine;
}

sub set_fileOutputCombineBurst {
    my ( $self, $fileOutputCombineBurst ) = @_;
    $self->{_fileOutputCombineBurst} = $fileOutputCombineBurst if $fileOutputCombineBurst;
}

sub set_fileOutputErrorAllelic {
    my ( $self, $fileOutputCombineBurst ) = @_;
    $self->{_fileOutputErrorAllelic} = $fileOutputErrorAllelic if $fileOutputErrorAllelic;
}

sub set_fileOutputCombineAllelicForUser{
    my ( $self, $fileOutputCombineBurst ) = @_;
    $self->{_fileOutputCombineAllelicForUser} = $_fileOutputCombineAllelicForUser if $_fileOutputCombineAllelicForUser;
}

#######################################
##This method use for combine file for make allelic profile.
#######################################
sub makeCombineAllele {
    my $filein   = $_[0]->{_inputName};
    my $pathName = $_[0]->{_pathName};
    my $str      = Bio::SeqIO->new(
        -file   => $pathName . $filein,
        -format => 'fasta'
    );

    my %tree;

    while ( my $seq_obj = $str->next_seq() ) {
        my @speNamesp;

        # print the sequence
        #print $seq_obj->display_id(),"\n";
        my @examples = split /-/, $seq_obj->display_id();
        my $example = $examples[ scalar(@speNamesp) - 1 ];
        print $seq_obj->desc, "\n";
        my @speNames = split /\|/, $seq_obj->desc;

        @speNamesp = split( ' ', $speNames[2] );

        #my $speciName = $speNamesp[0],( ),$speNamesp[1];
        my $strainName = $speNamesp[ scalar(@speNamesp) - 1 ];

        #my $name = "$speciName-$strainName";
        my $name = "$strainName";

        #my $name = "-";
        #print "$name\n";
        my $gene = $speNames[3];

        #print $gene;

        #print $seq_obj->seq,"\n"
        my @genenum = split /-/, $gene;
        if ( exists $tree{$example} ) {
            $tree{$example}{ $genenum[0] } = $genenum[1];
        }
        else {
            $tree{$example}
                = { "$genenum[0]" => $genenum[1], "name" => $name };
        }
        print $tree{$example}{ $genenum[0] }, " allele number \n";
    }

    print "#######################################\nFinish get allele number.\n##################################################\n";

    my $maxAllelic = findMaxAllelicName(\%tree);
    print "$maxAllelic this is max number \n";
    my @allAllele =  getAllAlleleName(\%tree, $maxAllelic);
    foreach my $allele (@allAllele) {
        print $allele."\n";
    }
    # return 0;
    my $treein="";
    my $burstin="";
    my $errorAllelic="example-data\t";
    my $user="example-data\t";

    foreach my $alleleHead ( @allAllele ){
        $errorAllelic .= "$alleleHead\t";
        $user .= "$alleleHead\t";
    }
        $errorAllelic .= "\n";
        $user .= "\n";

    # sort {$a <=> $b} is sort by number.
    foreach my $ex ( sort { $a <=> $b } keys %tree ) {
        print "example from user name spe is $ex \n";
        #$treein .= "$ex-$tree{$ex}{\"name\"}\t";

        if (scalar(keys $tree{$ex})  < $maxAllelic){
            $errorAllelic .= "example-$ex";
            
            foreach my $alleleHead ( @allAllele ){
                # print "$alleleHead => $tree{$ex}{$alleleHead}\n" if exists $tree{$ex}{$alleleHead}; 
                print $errorAllelic .= "\t" unless defined $tree{$ex}{$alleleHead};                   
                if ($tree{$ex}{$alleleHead}){
                    $errorAllelic .= "$tree{$ex}{$alleleHead}\t" 
                }
            }

            $errorAllelic .= "\n";

        }elsif (scalar(keys $tree{$ex}) == $maxAllelic) {
            $treein .= "example-$ex\t";
            $burstin .= "$ex\t";
            $user .= "example-$ex\t";

            foreach my $key ( sort keys $tree{$ex} ) {
                print "$key => $tree{$ex}{$key}\n";
                next if ( $key eq 'name' ) ;
                $treein .= "$tree{$ex}{$key}\t";
                $burstin .= "$tree{$ex}{$key}\t";
                $user .= "$tree{$ex}{$key}\t";
            }

            $burstin .= "\n";
            $treein .= "\n";         
            $user .= "\n"; 
        }

        print "\n"; 
    }

    if ( $errorAllelic ne ""){
        makeTreeFile( $errorAllelic, $_[0]->{_pathName}, $_[0]->{_fileOutputErrorAllelic} );    
    }    

    makeTreeFile( $treein, $_[0]->{_pathName}, $_[0]->{_fileOutputCombine} );
    makeTreeFile( $burstin, $_[0]->{_pathName}, $_[0]->{_fileOutputCombineBurst} );
    makeTreeFile( $user, $_[0]->{_pathName}, $_[0]->{_fileOutputCombineAllelicForUser} );

    return $treein;

}

###########################################
#This subroutine find max allelic each example data.
###########################################
sub findMaxAllelicName{
    my %tree = %{$_[0]};
    my @number;
    foreach my $ex ( sort { $a <=> $b } keys %tree ) {            
        push (@number, scalar(keys $tree{$ex}));
    }        
    return max @number;  
}

sub getAllAlleleName{
    my %tree = %{$_[0]};
    my $max = $_[1];
    my @listAllele;
    foreach my $ex ( sort { $a <=> $b } keys %tree ) {            
        if ( scalar(keys $tree{$ex}) == $max ){
            foreach my $key ( sort keys $tree{$ex} ) {
                next if ( $key eq 'name' ) ;
                push (@listAllele, $key);
            }
            return @listAllele;
        }
    }        

}

#######################################
#make file have argument is alegicProfile.
#argument 1 is treefile
#argument 2 is pathName
#argument 3 is filename
#output file name is allelicProfile.txt.
#######################################
sub makeTreeFile {
    my $tree     = $_[0];
    my $paths    = $_[1];
    my $filename = $_[2];
    my $path     = ">" . $paths . $filename;

    #make file output to AlegicProfile formake tree.
    open FH, $path or die "could not open \"$path\": $!";
    print FH $tree;
    close(FH);
    print $tree ;
}

1;

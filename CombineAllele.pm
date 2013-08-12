package CombineAllele;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use warnings;

#my $tre = makeProfile('testfile.fasta');
#makeTree($tre);
#This method want to argument filein for filename input.

sub new {
    my ( $class, %arg ) = @_;
    my $self = bless {
        _inputName => $arg{inputName} || "no input filename",
        _pathName  => $arg{pathName}  || "No path name",
        _tree      => $arg{tree}      || "DBMlstUse",
        _fileOutputCombine => "alegicProfile.txt"
    }, $class;

    return $self;
}

sub get_inputName         { $_[0]->{_inputName} }
sub get_pathName          { $_[0]->{_pathName} }
sub get_tree              { $_[0]->{_tree} }
sub get_fileOutputCombine { $_[0]->{_fileOutputCombine} }

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
        print $tree{$example}{ $genenum[0] }, "\n";
    }
    my $treein;

    # sort {$a <=> $b} is sort by number.
    foreach my $ex ( sort { $a <=> $b } keys %tree ) {
        print "name spe is $ex \n";
        $treein .= "$ex-$tree{$ex}{\"name\"}\t";

        foreach my $key ( sort keys $tree{$ex} ) {
            print "$key => $tree{$ex}{$key}\n";
            if ( $key eq 'name' ) {
                next;
            }
            $treein .= "$tree{$ex}{$key}\t";
        }
        $treein .= "\n";
        print "\n";
    }

    makeTreeFile( $treein, $_[0]->{_pathName}, $_[0]->{_fileOutputCombine} );

    return $treein;

}

#make file have argument is alegicProfile.
#output file name is alegicProfile.txt.
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

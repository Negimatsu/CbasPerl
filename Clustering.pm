package Clustering;

use LWP::UserAgent;
use warnings;
use strict;

sub new{
	my ($class,%arg)  = @_;
	my $self = bless{
		_inputCombine		=> $arg{inputCombine} 		|| "no input filename",
		_pathName			=> $arg{pathName}		|| "No path name",
		_fileOutBurst		=> "burst",
		_filePicCladogram 	=> "cladogram.eps",
		_filetreeCladogram	=> "treeCladogram.txt",
		_fileDBname		=> $arg{fileDBname}		|| ""
		},$class;
	return $self;
	}
	
sub get_inputCombine		{ $_[0] -> {_inputCombine}			}
sub get_pathName			{ $_[0] -> {_pathName}				}
sub get_fileOutBurst		{ $_[0] -> {_fileOutBurst}			}
sub get_fileOutCladogram	{ $_[0] -> {_filePicCladogram}		}


sub set_inputCombine {
	my ($self, $inputCombine) = @_;
	$self -> {_inputCombine} = $inputCombine if $inputCombine;
	}

sub set_pathName {
	my ($self, $pathName) = @_;
	$self -> {_pathName} = $pathName if $pathName;
	}
	
sub set_fileOutBurst {
	my ($self, $fileOutBurst) = @_;
	$self -> {_fileOutBurst} = $fileOutBurst if $fileOutBurst;
	}
	
sub set_fileOutCladogram {
	my ($self, $filePicCladogram) = @_;
	$self -> {_filePicCladogram} = $filePicCladogram if $filePicCladogram;
	}	


#this method want to argument parse string for make tree.
sub makeTree{
	my $data = $_[0] -> {_inputCombine};
	my $pathName = $_[0] -> {_pathName};
	my $url2 = 'http://pubmlst.org/perl/mlstanalyse/mlstanalyse.pl';
	# my $data = 'ST-11	2	3	4	3	8	4	6
	# ST-1149	2	3	4	53	8	4	6
	# ST-658	2	3	4	3	8	110	20
	# ST-50	2	3	19	3	8	4	6
	# ST-578	2	3	4	1	8	4	6
	# ST-211	2	3	4	8	8	4	6
	# ST-51	2	3	4	23	8	6	6
	# ST-67	2	3	4	24	8	4	6
	# ST-214	2	3	4	3	48	4	6
	# ST-473	2	3	15	3	8	4	6
	# ST-475	8	3	4	3	8	4	6
	# ST-654	8	3	4	3	14	5	6
	# ST-655	2	3	4	3	6	4	6
	# ST-1026	2	3	4	3	8	4	7
	# ST-1410	2	3	4	3	8	20	6
	# ST-1789	150	3	4	3	8	4	6
	# ST-2704	2	3	4	3	8	214	6
	# ST-2962	2	3	4	3	8	4	21
	# ST-2994	2	3	4	3	8	248	6
	# ST-52	7	3	4	3	8	4	6
	# ST-165	2	3	4	48	8	4	6
	# ST-166	2	3	6	3	3	58	6
	# ST-247	2	3	4	5	8	4	6
	# ST-285	8	3	4	3	51	5	6
	# ST-339	2	3	4	3	8	4	52
	# ';
	my %feildInput = ( 	'profiles' 	=> 	$data ,
						'site' 		=> 	'pubmlst',
						'page'		=> 	'treedraw',
						'referer'	=>	'pubmlst.org',
						'tree'		=>	'Neighbor-joining',
						'.cgifields'=>	'tree');
	my $contentHtml = post_url( $url2, \%feildInput );
	my @searchTreehtml = split '">Tree file</a>',$contentHtml ;
	my @nametre = split 'href="/tmp/',$searchTreehtml[0];
	my @testt = split 'TREEAPP_STRING_DATA',$contentHtml;
	my @testt2 = split '" />',$testt[1];
	my @testtCluster = split '="',$testt2[0];
	
	print $testtCluster[1],"\n";
	print "\n";

	#my $urlDown = "http://pubmlst.org/tmp/".$nametre[1];
	
	##print post_url( $url );
	#my $tree = post_url( $urlDown)  ;
	#print $tree;

	my $tree =$testtCluster[1];
	print $tree;
	save_file($tree,$_[0] -> {_pathName},$_[0] -> {_filetreeCladogram}	);

	make_PictureCladogram($tree,$_[0] -> {_pathName},$_[0] -> {_filePicCladogram});
	
	# use Bio::TreeIO;
	# use IO::String;

	# my $io = IO::String->new($tree);
	 
	# my $in = new Bio::TreeIO(-fh => $io,
	#                          -format => 'newick');
	# my $out = new Bio::TreeIO(-file => '>mytree.svg',
	#                           -format => 'svggraph');
	# while( my $tree = $in->next_tree ) {
	#     $out->write_tree($tree);
	# }
	
	
	}
	
sub make_PictureCladogram{
	
	my $tree 		= $_[0];
	my $paths		= $_[1];
	my $filename 	= $_[2];
	my $path 		= $paths.$filename;
	use Bio::Tree::Draw::Cladogram;
	use Bio::TreeIO;

	my $io = IO::String->new($tree);
	my $treeio = Bio::TreeIO->new(	'-format' 	=> 'newick',
									'-fh'   	=> $io);
	my $t1 = $treeio->next_tree;
	my $t2 = $treeio->next_tree;

	my $obj1 = Bio::Tree::Draw::Cladogram->new(-tree => $t1);
	$obj1->print(-file => $path);
	system("convert -resize \"768x1024\" -colorspace RGB -flatten -density 300 ".$paths."cladogram.eps ".$paths."treeprint.png");
	# system("convert -resize \"".$sizeImage."\" -colorspace RGB -flatten -density 300 ".$pathName."cladogram.eps ".$pathName."treeprint.png");
	print "convert ".$paths."cladogram.eps ".$paths."treeprint.png\n";
	}


sub post_url {
	my( $url, $formref ) = @_;

	# set up a UserAgent object to handle our request
	my $connect = new LWP::UserAgent(timeout => 300);

	$connect->agent('perlproc/1.0');

	my $response = $connect->post($url, $formref );

	if( $response -> is_success ){
		return $response->content;
	} else {
		return undef;
	}
}
sub save_file{
	my $tree = $_[0];
	my $paths = $_[1];
	my $filename = $_[2];
	my $path = ">".$paths.$filename;
	#make file output to AlegicProfile formake tree.
	open 	FH , $path or die "could not open \"$path\": $!";
	print 	FH $tree;
	close	(FH);
	print $path,"\n";
}

1;

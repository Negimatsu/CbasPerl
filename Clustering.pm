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


#######################################
##This method use for make phylogenetic from pubmlst
##This method want to argument parse string for make tree.
#######################################
sub makePhylogeneticTree{
	my $data = $_[0] -> {_inputCombine};
	my $pathName = $_[0] -> {_pathName};
	my $url2 = 'http://pubmlst.org/cgi-bin/mlstanalyse/mlstanalyse.pl';

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

	my $tree =$testtCluster[1];
	print $tree;
	save_file($tree,$_[0] -> {_pathName},$_[0] -> {_filetreeCladogram}	);

	make_PictureCladogram($tree,$_[0] -> {_pathName},$_[0] -> {_filePicCladogram});
}

#####################################
##This method use for create file Cladogram through command line in Unix.
##argument 1 is tree format (.tre).
##argument 2 is pathfile for save.
##argument 3 is file name for save.
#######################################	
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

#####################################
##This method use for sendfile allelicProfile to program eburst through web.
##argument 1 is file name allelicProfile
##
#######################################
sub makeEburst{
	my $file = $_[1];
	my $pathName = $_[0] -> {_pathName};
	my $eburstUrl = 'http://eburst.mlst.net/v3/enter_data/file.asp?select=7';
	
	my $contentHtml = postFile_url( $eburstUrl, $file );
	my @searchJnlpLink = split 'class=navlink href="..' ,$contentHtml;
	my @cutfile = split '"> Click' , $searchJnlpLink[1];
	my $fileInWeb = $cutfile[0];

	my $downloadLink = "http://eburst.mlst.net/v3/$fileInWeb";

	downloadFile($downloadLink, "$pathName/burstFromEburst.jnlp");
	
}

#################################
##This method use for save file from txt
##argument 1 is file for save.
##argument 2 is pathname for save.
##argument 3 is filename for save.
################################
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


####################################
##This method use for send post method to web page use for upload file
##argument 1 is url for downlad.
##argument 2 is filename for upload.
##Return Html code form request page
################################
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

####################################
##This method use for send post method to web page use for upload file
##argument 1 is url for downlad.
##argument 2 is filename for upload.
##Return Html code form request page
####################################
sub postFile_url{
	my( $url, $file ) = @_;
	my $ua = LWP::UserAgent->new;
	$ua->timeout(300);
	my $field_name = "FILE1";

	my $response = $ua->post( $url,
			Content_Type => 'form-data',
			Content => [ $field_name => ["$file"] ,
						'no_loci'	=>	'7',
						'saveto'	=>	'disk',
						'saveto'	=>	'database',]
			);
	return $response->content;
}

##########################################
##This method use for download file frome link
##argument 1 is url for downlad.
##argument 2 is filename for save.
###########################################
sub downloadFile{
	use LWP::Simple;
	my ($url,$renameFile) = @_;
	my $status = getstore($url, $renameFile);
 
	if ( is_success($status) ){
  		print "file downloaded correctly\n";
	}
	else
	{
  		print "error downloading file: $status\n";
	}
}


1;

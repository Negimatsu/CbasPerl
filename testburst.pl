use Clustering;
use CombineAllele;
my $pathname = '../UserData/9/';

my $combine = CombineAllele->new(	inputName 	=> 	'MlstFile.fasta',
									pathName 	=>	$pathname);
my $combineOut = $combine->makeCombineAllele;

my $cluster = Clustering->new (	inputCombine 	=> $combineOut,
								pathName 	=> $pathname,
								);

print "#####################\n##############################\n#######################";
$cluster->connectEburst("testburst.txt");
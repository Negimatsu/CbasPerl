#!/usr/bin/perl
use warnings;
use IdentifySequence;
use IdentifyAllele;
use CombineAllele;
use Clustering;
use AssignUnknown;
use warnings;
use strict;

# my $filename ='Unknown.fasta';
# my $pathname = '../UserData/9/';
my $mlstFile = "knownMlst.fasta";
my $unknownFilename = "unknown.fasta";

my $filename = $ARGV[0];
my $pathname = $ARGV[1];
my $isBacteria = $ARGV[2];


# my $IdentifySpe = IdentifySequence->new(
# 				inputName 	=> 	$filename,
# 				pathName 	=>	$pathname);
# $IdentifySpe->SearchBlast;
# $IdentifySpe->Annotate;

print $ARGV[2];

unless($isBacteria eq "no"){
	my $IdentifyAllele = IdentifyAllele->new(
	 					inputName 	=> 	"annotateSpecies.fasta",
	 					pathName 	=>	$pathname,
	 					dblistName	=> "DBMlstUse.txt");
	$IdentifyAllele->searchInMLST;
}else{
	$unknownFilename = "annotateSpecies.fasta";
}

if( (-e "$pathname$unknownFilename") || $isBacteria eq "no" ){

	my $Unknownfile = AssignUnknown->new(inputName 	=> 	$unknownFilename,
										pathName 	=>	$pathname);
	$Unknownfile->createUnknown();
	$Unknownfile->compoundFile($mlstFile);
	$mlstFile = 'MlstFile.fasta';
}

my $combine = CombineAllele->new(	inputName 	=> 	$mlstFile,
									pathName 	=>	$pathname);
my $combineOut = $combine->makeCombineAllele;

my $cluster = Clustering->new (	inputCombine 	=> $combineOut,
								pathName 	=> $pathname,
								);
my $tree = $cluster->makeTree;

1;

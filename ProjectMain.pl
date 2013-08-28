#!/usr/bin/perl
use warnings;
use IdentifySequence;
use IdentifyAllele;
use CombineAllele;
use Clustering;
use AssignUnknown;
use warnings;
use strict;

#my $filename ='Unknown.fasta';
#my $pathname = '../UserData/9/';
my $mlstFile = 'knownMlst.fasta';
my $filename = $ARGV[0];
my $pathname = $ARGV[1];
# print 'first';

my $IdentifySpe = IdentifySequence->new(
				inputName 	=> 	$filename,
				pathName 	=>	$pathname);
$IdentifySpe->SearchBlast;
$IdentifySpe->Annotate;

 my $IdentifyAllele = IdentifyAllele->new(
 					inputName 	=> 	"annotateSpecies.fasta",
 					pathName 	=>	$pathname,
 					dblistName	=> "DBMlstUse.txt");
$IdentifyAllele->searchInMLST;

# print "\n",'second';

unless (-e "..UserData/9/unknown.fasta"){
	my $Unknownfile = AssignUnknown->new(inputName 	=> 	"unknown.fasta",
										pathName 	=>	$pathname);
	$Unknownfile->createUnknown();
	$Unknownfile->compoundFile("knownMlst.fasta");
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

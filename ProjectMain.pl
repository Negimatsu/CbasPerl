#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin";
use warnings;
use IdentifySequence;
use IdentifyAllele;
use CombineAllele;
use Clustering;
use AssignUnknown;
use Percentfile;
use ValidateFasta;
use warnings;
use strict;

# my $filename ='Unknown.fasta';
# my $pathname = '../UserData/9/';
my $mlstFile = "knownMlst.fasta";
my $knownFile = "asgUknown.fasta";
my $unknownFilename = "unknown.fasta";


my $filename = $ARGV[0];
my $pathname = $ARGV[1];
my $isBacteria = $ARGV[2];
my $percent = Percentfile->new(	pathName 	=>	$pathname);
$percent->open_file;
$percent->add_word("A",5);

my $CheckFile = ValidateFasta->new(
				inputName 	=> 	$filename,
 				pathName 	=>	$pathname);

unless ($CheckFile->check_file eq 'true'){
	print STDERR "This file fasta have wrong display id format. You should check your file.";
	exit 0;
}
$percent->add_word("B",10);

my $IdentifySpe = IdentifySequence->new(
 				inputName 	=> 	$filename,
 				pathName 	=>	$pathname);
# $IdentifySpe->SearchBlastFromNCBI;
$IdentifySpe->SearchBlastFromLocalDB;
$percent->add_word("C",35);
$IdentifySpe->Annotate;
$percent->add_word("D",45);

unless($isBacteria eq "false"){
	my $IdentifyAllele = IdentifyAllele->new(
	 					inputName 	=> 	"annotateSpecies.fasta",
	 					pathName 	=>	$pathname,
	 					dblistName	=> "DBMlstUse.txt");
	$IdentifyAllele->searchInMLST;
	$percent->add_word("E",60);
}else{
	$unknownFilename = "annotateSpecies.fasta";
	$percent->add_word("F",60);
}

if ($isBacteria eq "false"){	
	my $Unknownfile = AssignUnknown->new(inputName 	=> 	$unknownFilename,
										pathName 	=>	$pathname);
	$Unknownfile->createUnknown();
	$mlstFile = "asgUnknown.fasta";	
}
$percent->add_word("G",70);
if( (-e "$pathname$unknownFilename") ){
	
	my $Unknownfile = AssignUnknown->new(inputName 	=> 	$unknownFilename,
										pathName 	=>	$pathname);
	$Unknownfile->createUnknown();
	$Unknownfile->compoundFile($mlstFile);
	$mlstFile = 'MlstFile.fasta';
}
$percent->add_word("H",80);

my $combine = CombineAllele->new(	inputName 	=> 	$mlstFile,
									pathName 	=>	$pathname);
my $combineOut = $combine->makeCombineAllele;
$percent->add_word("I",85);
my $cluster = Clustering->new (	inputCombine 	=> $combineOut,
								pathName 	=> $pathname);
my $tree = $cluster->makePhylogeneticTree;
$percent->add_word("J",95);
$cluster->makeEburst("$pathname"."allelicProfileBurst.txt");
$percent->add_word("K",100);

$percent->add_done;

1;
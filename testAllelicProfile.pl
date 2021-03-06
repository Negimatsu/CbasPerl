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

my $mlstFile = 'MlstFile.fasta';
my $pathname = $ARGV[0];

my $check = ValidateFasta -> new(inputName 	=> 	"MlstFile.fasta",
	 					pathName 	=>	$pathname);
$check->check_file;


# my $mlstFile = 'MlstFile.fasta';
# my $pathname = $ARGV[0];

# my $IdentifyAllele = IdentifyAllele->new(
# 	 					inputName 	=> 	"annotateSpecies.fasta",
# 	 					pathName 	=>	$pathname,
# 	 					dblistName	=> "DBMlstUse.txt");
# $IdentifyAllele->searchInMLST;


# return 0;
# my $combine = CombineAllele->new(	inputName 	=> 	$mlstFile,
# 									pathName 	=>	$pathname);
# my $combineOut = $combine->makeCombineAllele;
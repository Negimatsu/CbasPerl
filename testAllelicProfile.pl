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
use warnings;
use strict;

my $mlstFile = 'MlstFile.fasta';
my $pathname = $ARGV[0];
my $combine = CombineAllele->new(	inputName 	=> 	$mlstFile,
									pathName 	=>	$pathname);
my $combineOut = $combine->makeCombineAllele;
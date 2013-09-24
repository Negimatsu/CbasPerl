use Percentfile;
use warnings;
use strict;

my $pathname = './';
my $percent = Percentfile->new(	pathName 	=>	$pathname);
$percent->open_file;
my $percentInit = 0;
$percentInit = $percentInit+5;
$percent->add_word("a",$percentInit);
$percent->add_word("c",30);
$percent->add_word("b",30);
$percent->add_done;
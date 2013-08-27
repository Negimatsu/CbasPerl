package UnknownSequenceName;

use strict;
use warnings;


my %dataSequenceName;
my $size = 1;
use constant false => 0;
use constant true  => 1;

sub new {
   	my $self = {};
	bless ($self, "UnknownSequenceName");
	return $self;
}

sub addSequence{
	my $sequence = $_[0];
	my $name = "0$size";
	$dataSequenceName{$sequence} = $name;
	$size = $size+1;
}

sub getSequenceName{
	my $sequence = $_[0];
	return ($dataSequenceName{$sequence});
}

sub getHash{
	return (%dataSequenceName);
}
1;




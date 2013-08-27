package Unknown;

#use warnings;
use Data::Dumper;
use feature 'say';


#########################################
#this Class use for create Unknown fasta.
#use by new this object and getNameAllele(allelename,sequence)
#have attribute is hashmap alleleHash which key is allelename and value is hashmap that 
#hash map key is sequence and value is name for allele.
#########################################
sub new{
	my ($class,%arg)  = @_;
	my $self = bless{
		_unknownFasta		=> $arg{unknownFasta} 	|| "no input filename",
		},$class;
	return $self;
}

#Attribuite
my %alleleHash = ();


#########################################
##This method use for return allele name
## argument1 is allele name.
## argument2 is sequence.
## return <allelename>-<number front zero> Ex.adk-01
########################################
sub getNameAllele{
	my $alleleName = $_[1];
	my $sequence = $_[2];
	# say Dumper($_);
 	# say Dumper($sequence);

	if (exists ($alleleHash{$alleleName})){

		unless (exists $alleleHash{$alleleName}{$sequence}) {
			addSequenceHash($alleleName,$sequence);	
		}	
	}else{
		newSequenceHash($alleleName,$sequence);
		
	}
	$orderAllele = getSequenceName($alleleName,$sequence);
	$nameForFasta = "$alleleName-$orderAllele";
	return $nameForFasta;

}

#########################################
##This method use for new object hashmap each allele name
## and Each allele name is sequence is key ,and value is name.
## argument1 is allele name.
## argument2 is sequence.
########################################
sub newSequenceHash{
	my $alleleName = $_[0];
	my $sequence = $_[1];
	# print $sequence;

	my $size = 1;

	my $name = "0$size";
	$size = $size + 1 ;
	
	my %hashSequence = ($sequence => $name,'size' => $size);
	$alleleHash{$alleleName}{$sequence} =  $name;
	$alleleHash{$alleleName}{'size'} = $size;
	
}

#########################################
##This method use for add sequence for get name.
## argument1 is allele name.
## argument2 is sequence.
########################################
sub addSequenceHash{
	my $alleleName = $_[0];
	my $sequence = $_[1];

	# print $alleleName;
	#print $sequence;
	my $size = $alleleHash{$alleleName}{'size'};
	my $name = "0$size";
	$size++;
	$alleleHash{$alleleName}{$sequence} = $name;
	$alleleHash{$alleleName}{'size'} = $size;
	
	# while (($key, $value) = each $alleleHash{$alleleName})
	# {
 #  		print "$key \n";#;is $alleleHash{$alleleName}{$key} years old\n";
	# }
}

#########################################
##This method use get name.
## argument1 is allele name.
## argument2 is sequence.
########################################
sub getSequenceName{
	my $alleleName = $_[0];
	my $sequence = $_[1];

	return $alleleHash{$alleleName}{$sequence};
}

sub createFasta{

}
1; 


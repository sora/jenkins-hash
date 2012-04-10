use strict;
use warnings;

my $nwords = shift;

my @rules = ('0'..'9', 'a'..'z', 'A'..'Z');
my $nr    = @rules;

for (1 .. $nwords) {
  print unpack ("H*", $rules[int(rand($nr))]), "\n";
}


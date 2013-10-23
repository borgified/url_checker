#!/usr/bin/env perl

my $comment = <<EOC
for simplicity, i'll avoid using github api and just fetch
https://raw.github.com/vhf/free-programming-books/master/README.md
and based on the contents of this file, pick out all the references
to free-programming-books-*.md to iterate on
EOC
;

use warnings;
use strict;

use LWP::Simple;

my $readme = get('https://raw.github.com/vhf/free-programming-books/master/README.md');

my @lines=split(/\n/,$readme);
foreach my $line (@lines){
	if($line=~/ (\bfree-programming-books-?.*?\.md\b)/){
		print $1."\n";
	}
}

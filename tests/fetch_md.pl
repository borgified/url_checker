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

my $url='https://raw.github.com/vhf/free-programming-books';

my $readme = get($url."/master/README.md");

my @lines=split(/\n/,$readme);
foreach my $line (@lines){
	if($line=~/ (\bfree-programming-books-?.*?\.md\b)/){
		print $url."/master/".$1."\n";
	}
}

#raw files have the form:
#https://raw.github.com/vhf/free-programming-books/master/free-programming-books-ch.md


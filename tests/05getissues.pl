#!/usr/bin/env perl

use warnings;
use strict;
use Pithub;
use Data::Dumper;

my %config = do '/secret/github.config';

my $i      = Pithub::Issues->new( token => $config{'token'} );
my $result = $i->list(
	user    => 'borgified',
	repo    => 'test_issue',
	params => {
		state     => 'open',
		labels    => ['url_checker','ja'],
	}
);

while ( my $row = $result->next) {
	print $row->{title},"\n";
}


#print Dumper($result);

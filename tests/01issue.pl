#!/usr/bin/env perl

use warnings;
use strict;
use Pithub;
use Data::Dumper;

my %config = do '/secret/github.config';

my $i = Pithub::Issues->new( token => $config{'token'} );
my $result = $i->create(
	user => 'borgified',
	repo => 'test_issue',
	data => {
		body      => "I'm having a problem with this.",
		labels    => [ 'Label1' ],
		title     => 'found bad url'
	}
);


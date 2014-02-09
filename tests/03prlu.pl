#!/usr/bin/env perl
use warnings;
use strict;
use Pithub;
use Data::Dumper;


my %config = do '/secret/github.config';

my $p = Pithub::PullRequests->new( token => $config{'token'} );

my $result = $p->list(
	user => 'vhf',
	repo => 'free-programming-books',
);

print Dumper($result);

#use systemcall git log -Shttp://cran.r-project.org/doc/contrib/Mousavi-R-lang_in_Farsi.pdf

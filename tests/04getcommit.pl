#!/usr/bin/env perl
use warnings;
use strict;
use Pithub;
use Data::Dumper;


my %config = do '/secret/github.config';

my $c = Pithub::Repos::Commits->new( token => $config{'token'});
my $result = $c->get(
	user => 'vhf',
	repo => 'free-programming-books',
	#sha  => 'bce75a0752d7de3e1042b84d7227f4aeeeff4dc5',
	sha  => '5f0dbffe66663ef105e4de524c71052bc3beeded',
);

print $result->content->{author}->{login};
#print Dumper($result);

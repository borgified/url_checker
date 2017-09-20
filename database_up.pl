#!/usr/bin/env perl

use warnings;
use strict;
#use LWP::UserAgent;
#use HTTP::Cookies;
use URI::Find::UTF8;
use MongoDB();
use Data::Dumper qw(Dumper);
						      
my $client = MongoDB->connect();
my $db = $client->get_database( 'data' );
my $url_collection = $db->get_collection('urls');

#check if we have the original vhf/free-programming-books repo pulled down
#if not, do it, if so, grab the latest version

#if(-d "free-programming-books"){
#	chdir("free-programming-books");
#	#grab the latest changes
#	system("git pull origin master >/dev/null 2>&1");
#	chdir("../.");
#}else{
#	system("git clone https://github.com/vhf/free-programming-books.git >/dev/null 2>&1");
#}
#
#chdir("free-programming-books");
#my @books = <free-programming-books*.md>;
#
##gotta add 2 more books that dont conform to the usual naming convention
#push(@books,'free-courses-en.md');
#push(@books,'free-podcasts-screencasts-cs.md');
#push(@books,'free-podcasts-screencasts-en.md');
#push(@books,'free-podcasts-screencasts-pt_BR.md');
#push(@books,'free-podcasts-screencasts-ru.md');
#push(@books,'free-podcasts-screencasts-se.md');
#push(@books,'javascript-frameworks-resources-pt_BR.md');
#push(@books,'javascript-frameworks-resources.md');
#push(@books,'problem-sets-competitive-programming.md');
#push(@books,'free-programming-interactive-tutorials-en.md');
#push(@books,'free-programming-playgrounds.md');
## @books now contains all the different "books".md

########### added next 3 lines to limit database size for testing
chdir("free-programming-books");
my @books;
push @books, 'free-programming-playgrounds.md';

my %db;

#read all the contents of each *.md file inside @books and put it into %db
foreach my $book (sort @books){
	local $/ = undef;
	open FILE, "$book" or die "Couldn't open file: $!";
	my $content = <FILE>;
	close FILE;
	$db{$book}{"content"}=$content;
}

chdir("../.");

$|=1;

my $SUCCESS_LVL6 = 6; 
foreach my $book (keys %db){

#all content from each book goes into @content, each array item = 1 line
	my @content = split("\n", $db{$book}{'content'});

	my $setOnInsert;
	foreach my $line (@content){
		#if there are more than one url in one line, this will detect it too and
		#add them as separate entries into @uris
		my $finder = URI::Find::UTF8->new( sub {
				my($uri) = shift;
				
				# upsert to database	
				$url_collection->update_one(	{"url" => "$uri"},
				  														{ '$setOnInsert' => { url => "$uri", success_lvl => $SUCCESS_LVL6}},
																			{ 'upsert' => 1 }
				);
			
			});

		$finder->find(\$line);
	}
}
$|=0;

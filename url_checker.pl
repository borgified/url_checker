#!/usr/bin/env perl
use warnings;
use strict;
use Digest::SHA1 qw/sha1_hex/;
use LWP::UserAgent;
use Pithub;

my %config = do '/secret/github.config';

if(-d "free-programming-books"){
	chdir("free-programming-books");
	system("git pull");
	chdir("../.");
}else{
	system("git clone https://github.com/vhf/free-programming-books.git");
}

chdir("free-programming-books");
my @books = <free-programming-books*.md>;

my %db;

foreach my $book (@books){
	local $/ = undef;
	open FILE, "$book" or die "Couldn't open file: $!";
	my $content = <FILE>;
	close FILE;
	#print sha1_hex($content)," $book\n";
	my $sha = sha1_hex($content);


	#created a sha of each book. not sure what i want to do with it yet.
	#the intention was to check if a book changed and avoid check if 
	#there was no change but it looks like we should check all the urls
	#regardless.
	$db{$book}{"sha"}=$sha;
	$db{$book}{"content"}=$content;
}

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0");
$ua->timeout(120);
$ua->show_progress(1);

my $i = Pithub::Issues->new( token => $config{'token'} );
my $c = Pithub::Repos::Commits->new( token => $config{'token'});

#gather previously created issues still open so we dont recreate them
my %issues;
my $openissues = $i->list(
	### borgified/test_issue is a testing repo
	###
	###
	user    => 'borgified',
	repo    => 'test_issue',
	###
	###
	params => {
		state     => 'open',
		#####
		#####
		#label should just look for 'url_checker' for the prod version
		#####
		labels    => ['url_checker','ja'],
		#####
		#####
		#####
	}
);

while ( my $row = $openissues->next) {
	#the bad url is in the title
	#print $row->{title},"\n";
	$issues{$row->{title}}=0;
}

foreach my $book (keys %db){
	my @content = split("\n", $db{$book}{'content'});
	foreach my $line (@content){
		if($line =~ /\[.*\].*\(.*(http:\/\/.*?)\)/){
			#print "$1\n";
			my $url=$1;
			my $test = &test_url($url);

			## create issue only if the url was tested bad AND it doesnt 
			## already exist as an open issue.

			if($test ne 'good' && !exists($issues{$url}) ){
				my $lang="en";
				if($book =~ /free-programming-books-(.*)\.md/){
					$lang=$1;
				}

				#figure out which commit added this bad url
				my $commit = `git log -S$url --reverse --format=%H | head -1`;
				chomp($commit);

				#figure out the commit's author's login
				my $cc = $c->get(
					user => 'vhf',
					repo => 'free-programming-books',
					sha  => $commit,
				);

				my $committer = $cc->content->{author}->{login};

				###
				###
				### alter committers name for testing so we dont bother them
				$committer = $committer."klajdfl";
				###
				###
				###

				my $result = $i->create(
					#user => 'vhf',
					#repo => 'free-programming-books',
					###
					### borgified/test_issue is a testing repo
					###
					###
					user => 'borgified',
					repo => 'test_issue',
					###
					###
					data => {
						body      => "$test \nIt was added by \@$committer in $commit.",
						labels    => [ $lang, 'url_checker' ],
						title     => $url,
					}
				);

			}
		}
	}
}

sub test_url{
	my $retval;
	my $url = shift @_;
	my $req = HTTP::Request->new(HEAD => $url);
	my $res = $ua->request($req);
	if($res->is_success){
		$retval = "good";
	}else{
		#try one more time with GET
		$req = HTTP::Request->new(GET => $url);
		$ua->timeout(360); #wait 6 mins in case it's really slow
		$res = $ua->request($req);
		if($res->is_success){
			$retval = "good";
		}else{
			$retval = $res->status_line."\n$url";
		}
	}
	return $retval;
}

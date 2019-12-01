#!/usr/bin/env perl

use utf8;
use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::Find::UTF8;


#system("git clone https://github.com/EbookFoundation/free-programming-books.git /tmp/fpb");

chdir("/tmp/fpb");
my @books = <$ARGV[0]>;

my %db;

#read all the contents of each *.md file inside @books and put it into %db
foreach my $book (sort @books){
	local $/ = undef;
	open FILE, '<:encoding(UTF-8)', "$book" or die "Couldn't open file: $!";
	my $content = <FILE>;
	close FILE;
	$db{$book}{"content"}=$content;
}

chdir("../.");

my $cookies = HTTP::Cookies->new(
	file => "cookies.txt",
	autosave => 1,
);

#settings for checking url
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13 GTB7.1");
$ua->timeout(15);
$ua->cookie_jar($cookies);
#$ua->show_progress(1);

$|=1;
foreach my $book (keys %db){

	print "$book\n";

#all content from each book goes into @content, each array item = 1 line
	my @content = split("\n", $db{$book}{'content'});

	foreach my $line (@content){
		#if there are more than one url in one line, this will detect it too and
		#add them as separate entries into @uris
		my $finder = URI::Find::UTF8->new( sub {
				my($uri) = shift;
				my $result = &test_url($uri);
                                  if($result ne 'good'){
				    print "+ [ ] $result $uri\n";
                                  }
			});

		$finder->find(\$line);
	}
	print "\n";
}
$|=0;



# url testing here
# input: one url
# output: good if url is ok, http error if bad

sub test_url{
	my $retval;
	my $url = shift @_;

#try with HEAD (fastest)
	my $req = HTTP::Request->new(HEAD => $url);
	$req->header(Accept => "text/html, */*;q=0.1", referer => 'http://google.com');
	my $res = $ua->request($req);

	if($res->is_success){
		$retval = "good";
	}else{

#try again with GET
		$req = HTTP::Request->new(GET => $url);
		$req->header(Accept => "text/html, */*;q=0.1", referer => 'http://google.com');
		$ua->timeout(15); #wait 60 for the download
		$res = $ua->request($req);
		if($res->is_success){
			$retval = "good";
		}else{

#try again with curl
#beerpla.net/2010/06/10/how-to-display-just-the-http-response-code-in-cli-curl/
			my $http_code = `curl --max-time 60 -k -sL -w "%{http_code}" $url -o /dev/null`;
			if ($http_code eq '200'){
				$retval = "good";
			}else{
				#we tried multiple ways to get to the url but we failed
				$retval = $res->status_line;
			}
		}
	}
	return $retval;
}

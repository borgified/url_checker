#!/usr/bin/env perl

use warnings;
use strict;
use LWP::UserAgent;
use Pithub;
use HTTP::Cookies;

use URI::Find::UTF8;

#github accounts/passwords config
my %config = do '/secret/github.config';

#check if we have the original vhf/free-programming-books repo pulled down
#if not, do it, if so, grab the latest version

if(-d "free-programming-books"){
	chdir("free-programming-books");
	#grab the latest changes
	system("git pull origin master");
	chdir("../.");
}else{
	system("git clone https://github.com/vhf/free-programming-books.git");
}

chdir("free-programming-books");
my @books = <free-programming-books*.md>;

#gotta add 2 more books that dont conform to the usual naming convention
push(@books,'free-programming-interactive-tutorials-en.md');
push(@books,'javascript-frameworks-resources.md');
# @books now contains all the different "books".md


my %db;


#read all the contents of each *.md file inside @books and put it into %db
foreach my $book (@books){
	local $/ = undef;
	open FILE, "$book" or die "Couldn't open file: $!";
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
$ua->timeout(120);
$ua->cookie_jar($cookies);
#$ua->show_progress(1);

my $c = Pithub::Repos::Commits->new( token => $config{'token'});

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
				print "$result $uri\n";
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
		$ua->timeout(60); #wait 60 for the download
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



__END__


my $test = &test_url($url);

if($test ne 'good'){
my $lang="en";
if($book =~ /free-programming-books-(.*)\.md/){
$lang=$1;
}elsif($book eq 'javascript-frameworks-resources.md'){
$lang='jfr';
}elsif($book eq 'free-programming-interactive-tutorials-en.md'){
$lang='fpite';
}

#figure out which commit added this bad url
my $commit = `git log -S$url --reverse --format=%H | head -1`;
chomp($commit);

#figure out the commit's author's login so we take a closer
#look at this single commit and look for the login info
my $cc = $c->get(
user => 'vhf',
repo => 'free-programming-books',
sha  => $commit,
);
my $committer = $cc->content->{author}->{login};

print "$test\nIt was added by \@$committer in $commit. label: $lang\t title: $url\n";

}
}
}
}

sub test_url{
my $retval;
my $url = shift @_;
my $req = HTTP::Request->new(HEAD => $url);
my $res = $ua->request($req);

### CHANGE HERE TO THE MAKE HE CHECK LESS STRINGENT 

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

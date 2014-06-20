#!/usr/bin/env perl

use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Cookies;



sub main{
	my $url='https://computing.llnl.gov/?set=training&page=index';
	my $result = &test_url($url);
	print $result;
}



my $cookies = HTTP::Cookies->new(
	file => "cookies.txt",
	autosave => 1,
);

#settings for checking url
my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13 GTB7.1");
$ua->timeout(120);
$ua->cookie_jar($cookies);
$ua->show_progress(1);

&main;

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

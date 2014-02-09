#!/usr/bin/env perl
use warnings;
use strict;
use Digest::SHA1 qw/sha1_hex/;
use LWP::UserAgent;
use Pithub;

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/8.0");
$ua->timeout(120);
$ua->show_progress(1);

my $DATA = <<END;
http://typesafe.com/resources/book/scala-for-the-impatient
http://majesticseacreature.com/rbp-book/pdfs/rbp_1-0.pdf
http://www.djangobook.com/
http://www.cs.bris.ac.uk/~flach/SimplyLogical.html
http://www.gutenberg.org/ebooks/33283
http://cran.r-project.org/doc/contrib/Mousavi-R_topics_in_Farsi.pdf
http://rd.clojure-users.org/
http://cpp0x.pl/kursy/Kurs-OpenGL-C++/
END

my @urls = split("\n",$DATA);

foreach my $url (@urls){
	my $test = &test_url($url);
	if($test ne 'good'){
		print "bad link: $test $url\n";
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
			$retval = $res->status_line." $url";
		}
	}
	return $retval;
}

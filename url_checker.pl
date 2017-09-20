#!/usr/bin/env perl

use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use URI::Find::UTF8;
use MongoDB();
use Data::Dumper qw(Dumper);
use DateTime;
use Switch;

### Success Levels ###
my $SUCCESS_LVL0 = 0;
my $SUCCESS_LVL1 = 1;
my $SUCCESS_LVL2 = 2;
my $SUCCESS_LVL3 = 3;
my $SUCCESS_LVL4 = 4;
my $SUCCESS_LVL5 = 5;
my $SUCCESS_LVL6 = 6;

# Connect Database  
my $client = MongoDB->connect();
my $db = $client->get_database( 'data' );
my $url_collection = $db->get_collection('urls');


# Select $num random urls from database 
my $num=3;	
my @url;
my $doc_count = $url_collection->count();
for(my $i=0; $i<$num; $i++){
  my $step_size = int(rand(1) * $doc_count);	
  my $doc = $url_collection->find->skip($step_size)->next;
  push @url, $doc->{'url'};
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
#$ua->show_progress(1);

$|=1;

# Test Urls  
foreach my $url (@url){
  print "$url";
  my $result = test_url($url);	
  print " ==> $result\n";

# get document's timestamp and success_lvl to determine urgency of test
  my $doc = $url_collection->find({ 'url' => $url })->next;
  my $level = $doc->{'success_lvl'};
  my $timestamp = $doc->{'timestamp'};


# Case: New Url
  if(!$timestamp) { 
    print "Testing new url\n";
    my $result = test_url($url);

# Update document's timestamp and set success_lvl to 6 by default
    $timestamp = DateTime->now();	
    $url_collection->update_one	(
      {"url" => $url},
      { '$set' =>	{ url	=> $url, 
          success_lvl => $SUCCESS_LVL6,
          timestamp	=> $timestamp	}},
      { 'upsert' => 1 }
    );
# If attempt at url failed, decrease success_lvl by 1 
# Do nothing if good since new urls are set to max success_lvl 6 by default 
    if ($result ne "good") {
      print "decreasing success_lvl\n";
      $url_collection->update_one	(	
        { "url" => $url},
        { '$inc' =>	{ success_lvl => -1 }}, 
        { 'upsert' => 1 }
      );
    }


  }else{
### Case: Existing Url ###	

# calculate time since last test
    my $idle_time = DateTime->now() - $timestamp; 

    switch($level) {
      case $SUCCESS_LVL0: { 		}
      case $SUCCESS_LVL1: { 
         


      }
      case $SUCCESS_LVL2: { 		}
      case $SUCCESS_LVL3: { 		}
      case $SUCCESS_LVL4: { 		}
      case $SUCCESS_LVL5: { 		}
      case $SUCCESS_LVL6: { 		}
    }

#					print "Timestamp: $timestamp\n";
#					if ($result eq "good") {
#							print "good!!!\n";
#							if ($level != $SUCCESS_LVL6) {
#									# increase success_lvl
#									print "increasing\n";
#									$url_collection->update_one	(	{ "url" => $url},
#              																	{ '$inc' =>	{ success_lvl => 1 }}, 
#		          																	{ 'upsert' => 1 }
#																							);
#							}
#					}
  }
} # close foreach	


##########  Subroutines  ########## 
####  issue with not timing out:  "https://dotnetfiddle.net" and "http://cssdesk.com" issue with DNS resolving to multiple IPs? 
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
#update_level(test_url);
#input: result of test_url
sub update_level() {
  my($result)=@_; 
  if($result eq "good") {
    $url_collection->update_one	(	
      { "url" => $url},
      { '$inc' =>	{ success_lvl => 1 }}, 
      { 'upsert' => 1 }
    );
  }else{
    $url_collection->update_one	(	
      { "url" => $url},
      { '$inc' =>	{ success_lvl => -1 }}, 
      { 'upsert' => 1 }
    );
  }
}

__END__
################################################
#sub test_url {

#	foreach my $key (keys %$doc ) {
#	     my $val=$doc->{$key};
#			      print "$key->$val\n";
#						  }
#							  print "\n";
#								}


#my $cursor=$urls_coll->find->skip(5);
#while(my $doc=$cursor->next) {
#	foreach my $key (keys %$doc ){
#		if($key eq "url"){
#			print "$doc->{$key}\n";
#		}
#	}	
#}

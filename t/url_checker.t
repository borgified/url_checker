use Test::More;
use LWP::UserAgent;

open(INPUT,"../free-programming-books.md");


#BEGIN {plan tests => 3};
BEGIN; 

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/8.0");
$ua->timeout(10);
my $count=0;

while(defined(my $line=<INPUT>)){
	if($line=~/(http:\/\/.*?)\)/){
		my $req = HTTP::Request->new(GET => $1);
		my $res = $ua->request($req);
		ok($res->is_success,$1." ".$res->status_line);
		$count++;
	}
}

done_testing($count);

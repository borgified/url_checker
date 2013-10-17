use Test::More;
use LWP::UserAgent;

BEGIN {plan tests => 2};

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/8.0");

my $req = HTTP::Request->new(GET => 'http://www.perlmeme.org');
my $res = $ua->request($req);

ok($res->is_success,$res->status_line);

$req = HTTP::Request->new(GET => 'http://www.perlimeme.org');
$res = $ua->request($req);

ok($res->is_success,$res->status_line);

$req = HTTP::Request->new(GET => 'http://www.spathiwa.com');
$res = $ua->request($req);

ok($res->is_success,$res->status_line);

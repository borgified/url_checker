use Test::More;
use LWP::UserAgent;

BEGIN {plan tests => 1};

#eval { require LWP::UserAgent; return 1;};
#ok($@,'');
#croak() if $@;

my $ua = LWP::UserAgent->new;
$ua->agent("Mozilla/8.0");

my $req = HTTP::Request->new(GET => 'http://www.perlmeme.org');
my $res = $ua->request($req);

ok($res->is_success,$res->status_line);

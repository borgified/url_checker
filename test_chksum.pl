#!/usr/bin/env perl

use warnings;
use strict;

use LWP::Simple;
use Digest::SHA1 qw/sha1_hex/;

my $url='http://csb.stanford.edu/class/public/pages/sykes_webdesign/05_simple.html';

my $content = get($url);

print sha1_hex($content);

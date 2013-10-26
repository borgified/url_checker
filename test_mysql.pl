#!/usr/bin/env perl

use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:mysql:database=$ENV{OPENSHIFT_APP_NAME};host=$ENV{OPENSHIFT_MYSQL_DB_HOST}",$ENV{OPENSHIFT_MYSQL_DB_USERNAME},$ENV{OPENSHIFT_MYSQL_DB_PASSWORD});

eval{ $dbh->do("show tables") };
print "show tables failed: $@\n" if $@;



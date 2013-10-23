#!/usr/bin/env perl

use warnings;
use strict;

open(OUTPUT,">> $ENV{OPENSHIFT_LOG_DIR}/output_cron.log");

print OUTPUT localtime()."\n";

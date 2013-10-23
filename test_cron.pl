#!/usr/bin/env perl

use warnings;
use strict;

open(OUTPUT,">> output_cron");

print OUTPUT localtime."\n";

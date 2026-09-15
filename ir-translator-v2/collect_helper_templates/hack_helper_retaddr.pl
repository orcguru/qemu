#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV < 0) {
  print "Usage: ./script <accel_tcg_user-exec.c.o.E>\n";
  exit 1;
}

open IN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
open OUT, "> $ARGV[0].updated" or die "Cannot open $ARGV[0].update for write!\n";
while (<IN>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^\s+helper_retaddr\s+=\s+(.*)$/) {
    my $exp = $1;
    print OUT "    unsigned long *ptr = (unsigned long *)(env - 32);\n";
    print OUT "    *ptr = $exp\n";
    next;
  }
  print OUT "$line\n";
}
close IN;
close OUT;
`mv $ARGV[0].updated $ARGV[0]`;

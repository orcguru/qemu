#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Cwd 'abs_path';

my $file = basename($0);
my $scriptFolder = abs_path($0);
$scriptFolder =~ s/\/$file$//;
my $antlrAppPath = "$scriptFolder/parser";
my $antlrJarName = "antlr-4.9.3-complete.jar";

# Check antlr.jar
if (not -e "$antlrAppPath/$antlrJarName") {
  `which curl > /dev/null 2>&1`;
  if ($? == 0) {
    print "Downloading https://www.antlr.org/download/antlr-4.9.3-complete.jar\n";
    `curl https://www.antlr.org/download/antlr-4.9.3-complete.jar -o $antlrAppPath/$antlrJarName`;
  }
  if (not -e "$antlrAppPath/$antlrJarName") {
    print "Please download antlr runtime library from below link, put that under $antlrAppPath folder, and retry.\n";
    print "https://www.antlr.org/download/antlr-4.9.3-complete.jar\n";
    exit 1;
  }
}

# Build antlr/java
`cd $antlrAppPath && java -jar $antlrAppPath/$antlrJarName *.g4`;
`cd $antlrAppPath && javac -cp .:$antlrAppPath/$antlrJarName *.java`;

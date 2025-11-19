#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use File::Basename;
use Cwd 'abs_path';

if ($#ARGV < 1) {
  print "Usage: ./script <antlr-in> <antlr-out>\n";
  exit 1;
}
my %helpers = (
  "helper_cc_compute_all" => 1,
  "helper_cc_compute_c" => 1,
  "helper_cc_compute_nz" => 1,
);
my $path = "$ARGV[0].helper_cc";
`rm -rf $path`;
`mkdir -p $path`;
# Collect function definitions
my %funcs = ();
my %addr_to_func = ();
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<FunctionDefinition/) {
    my @fields = split(/\$\$/, $line);
    my $nameStart;
    my $nameStop;
    my $fullStart;
    my $fullStop;
    if ($#fields == 6) {
      my @f1 = split(/:/, $fields[1]);
      my @f2 = split(/:/, $fields[2]);
      my @f3 = split(/:/, $fields[3]);
      my @f4 = split(/:/, $fields[4]);
      my @f5 = split(/:/, $fields[5]);
      my @f6 = split(/:/, $fields[6]);
      $nameStart = $f1[1];
      $nameStop = $f2[1];
      $fullStart = $f5[1];
      $fullStop = $f4[1];
    } elsif ($#fields == 5) {
      my @f1 = split(/:/, $fields[1]);
      my @f2 = split(/:/, $fields[2]);
      my @f3 = split(/:/, $fields[3]);
      my @f4 = split(/:/, $fields[4]);
      my @f5 = split(/:/, $fields[5]);
      $nameStart = $f1[1];
      $nameStop = $f2[1];
      $fullStart = $f1[1];
      $fullStop = $f4[1];
    } else {
      die "function definition info error!\n";
    }
    my %info = ();
    $info{'NAME_START'} = $nameStart;
    $info{'NAME_STOP'} = $nameStop;
    $info{'FULL_START'} = $fullStart;
    $info{'FULL_STOP'} = $fullStop;
    my $func_name = &GetText($nameStart, $nameStop, $ARGV[0]);
    $func_name = &extract_func_name($func_name);
    $info{'FUNC_NAME'} = $func_name;
    $info{'FUNC_FULL'} = &GetText($fullStart, $fullStop, $ARGV[0]);
    my %calls = ();
    $info{'CALLS'} = \%calls;
    my %returns = ();
    $info{'RETURNS'} = \%returns;
    if (exists $funcs{$info{'FUNC_NAME'}}) {
      print "Duplicated function definition $info{'FUNC_NAME'}!\n";
      $info{'FUNC_NAME'} = $info{'FUNC_NAME'}."__DUPLICATED";
    }
    $funcs{$info{'FUNC_NAME'}} = \%info;
    if (exists $addr_to_func{$info{'FULL_START'}}) {
      die "Duplicated $info{'FULL_START'}!\n";
    }
    $addr_to_func{$info{'FULL_START'}} = $info{'FUNC_NAME'};
  }
}
close FD;
my @sorted_addr = sort {$a <=> $b} sort keys %addr_to_func;
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<FUNCTION_CALL2?>/) {
    my @fields = split(/\$\$/, $line);
    my %info = ();
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my @f3 = split(/:/, $fields[3]);
    my @f4 = split(/:/, $fields[4]);
    $info{'NAME_START'} = $f1[1];
    $info{'NAME_STOP'} = $f2[1];
    $info{'PAREN_START'} = $f3[1];
    $info{'PAREN_STOP'} = $f4[1];
    $info{'CALL_TARGET'} = &GetText($info{'NAME_START'}, $info{'NAME_STOP'}, $ARGV[0]);
    $info{'CALL_ARGUMENTS'} = &GetText($info{'PAREN_START'}, $info{'PAREN_STOP'}, $ARGV[0]);
    my $func_idx = &lookup_func($info{'NAME_START'});
    $funcs{$addr_to_func{$sorted_addr[$func_idx]}}->{'CALLS'}->{$info{'NAME_START'}} = \%info;
  } elsif ($line =~ /^<RETURN_VOID>/) {
    my @fields = split(/\$\$/, $line);
    my %info = ();
    $info{'TYPE'} = "RETURN_VOID";
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    $info{'RETURN_START'} = $f1[1];
    $info{'RETURN_STOP'} = $f2[1];
    my $txt = &GetText($info{'RETURN_START'}, $info{'RETURN_STOP'}, $ARGV[0]);
    if ($txt ne "return;") {
      die "RETURN_VOID format error:$txt\n";
    }
    my $func_idx = &lookup_func($info{'RETURN_START'});
    $funcs{$addr_to_func{$sorted_addr[$func_idx]}}->{'RETURNS'}->{$info{'RETURN_START'}} = \%info;
  } elsif ($line =~ /^<RETURN_EXPR>/) {
    my @fields = split(/\$\$/, $line);
    my %info = ();
    $info{'TYPE'} = "RETURN_EXPR";
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my @f3 = split(/:/, $fields[3]);
    my @f4 = split(/:/, $fields[4]);
    $info{'RETURN_START'} = $f1[1];
    $info{'RETURN_STOP'} = $f2[1];
    $info{'EXPR_START'} = $f3[1];
    $info{'EXPR_STOP'} = $f4[1];
    my $func_idx = &lookup_func($info{'RETURN_START'});
    $funcs{$addr_to_func{$sorted_addr[$func_idx]}}->{'RETURNS'}->{$info{'RETURN_START'}} = \%info;
  }
}
close FD;

# Collect background info (-function)
open FDIN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
my $current_pos = 0;
my $blank_info = "";
my $bytes;
foreach my $a (@sorted_addr) {
  my $txt = &GetText($current_pos, ($funcs{$addr_to_func{$a}}->{'FULL_START'} - 1), $ARGV[0]);
  $blank_info = $blank_info."\n".$txt;
  $current_pos = $funcs{$addr_to_func{$a}}->{'FULL_STOP'} + 1;
}
my $total_size = -s $ARGV[0];
my $txt = &GetText($current_pos, ($total_size - 1), $ARGV[0]);
$blank_info = $blank_info."\n".$txt;

# Generate functions
foreach my $f (keys %helpers) {
  open OUT, "> $path/$f.c" or die "Cannot open $path/$f.c for write!\n";
  print OUT "$blank_info\n\n";
  my @sub_funcs = ();
  my @sub_call_stack = ();
  if (not exists $funcs{$f}) {
    die "$f not defined!\n";
  }
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $call_target = $funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'};
    unshift @sub_funcs, $call_target;
    push @sub_call_stack, $call_target;
  }
  while (@sub_call_stack > 0) {
    my @new_call_stack = ();
    foreach my $c (@sub_call_stack) {
      if (not exists $funcs{$c}) {
        print "$c not defined!\n";
        next;
      }
      foreach my $e (keys %{$funcs{$c}->{'CALLS'}}) {
        my $call_target = $funcs{$c}->{'CALLS'}->{$e}->{'CALL_TARGET'};
        unshift @sub_funcs, $call_target;
        push @new_call_stack, $call_target;
      }
    }
    @sub_call_stack = @new_call_stack;
  }
  my %covered_sub_funcs = ();
  foreach my $s (@sub_funcs) {
    if (not exists $covered_sub_funcs{$s}) {
      $covered_sub_funcs{$s} = 1;
      if (exists $funcs{$s}) {
        print OUT "$funcs{$s}->{'FUNC_FULL'}\n\n";
      }
    }
  }
  print OUT "$funcs{$f}->{'FUNC_FULL'}\n";
  close OUT;
}

sub lookup_func
{
  my ($loc) = @_;
  my $low_idx = 0;
  my $high_idx = $#sorted_addr;
  while (($high_idx - $low_idx) != 1) {
    if (!($funcs{$addr_to_func{$sorted_addr[$low_idx]}}->{'FULL_START'} < $loc and $funcs{$addr_to_func{$sorted_addr[$high_idx]}}->{'FULL_START'} > $loc)) {
      die "BUG2\n";
    }
    my $middle_idx = int(($high_idx + $low_idx)/2);
    if ($funcs{$addr_to_func{$sorted_addr[$middle_idx]}}->{'FULL_START'} < $loc) {
      $low_idx = $middle_idx;
    } else {
      $high_idx = $middle_idx;
    }
  }
  if (!($funcs{$addr_to_func{$sorted_addr[$low_idx]}}->{'FULL_START'} < $loc and $funcs{$addr_to_func{$sorted_addr[$low_idx]}}->{'FULL_STOP'} > $loc)) {
    die "BUG3\n";
  }
  return $low_idx;
}

sub extract_func_name
{
  my ($input) = @_;
  $input =~ s/^\*+//;
  $input =~ s/^\s+//;
  $input =~ s/^\n+//;
  if ($input =~ /^__attribute__/) {
    my @chars = split(//, $input);
    my $paren_cnt = 0;
    my $start_idx = -1;
    foreach my $idx (0 .. $#chars) {
      my $c = $chars[$idx];
      if ($c eq "(") {
        $paren_cnt = $paren_cnt + 1;
      } elsif ($c eq ")") {
        $paren_cnt = $paren_cnt - 1;
        if ($paren_cnt == 0) {
          $start_idx = $idx + 1;
          last;
        }
      }
    }
    if ($start_idx == -1) {
      die "BUG!\n";
    }
    $input = "";
    foreach my $idx ($start_idx .. $#chars) {
      $input = $input.$chars[$idx];
    }
    $input =~ s/^\s*//;
    $input =~ s/^\n*//;
  }
  $input =~ s/^\(//;
  if ($input =~ /^([a-zA-Z0-9_]+)(\s|\(|\))/) {
    $input = $1;
  } else {
    die "Format error:$input\n";
  }
  return $input;
}

sub GetText
{
  my ($posStart, $posEnd, $cppFn) = @_;
  my $ret = "";

  open FDIN, "< $cppFn" or die "Cannot open $cppFn for read!\n";
  my $bytes;
  my $br = read FDIN, $bytes, $posStart;
  if ($br != $posStart) {
    die "Failed to read $cppFn\n";
  }
  $br = read FDIN, $bytes, ($posEnd - $posStart + 1);
  if ($br != ($posEnd - $posStart + 1)) {
    die "Failed to read $cppFn\n";
  }
  $ret = unpack "A*", $bytes;
  close FDIN;
  return $ret;
}

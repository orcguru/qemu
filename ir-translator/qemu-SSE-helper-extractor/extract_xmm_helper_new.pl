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

my %prefixMap = (
  "q" => ["unsigned long", "v2ulong"],
  "l" => ["unsigned int", "v4uint"],
  "w" => ["unsigned short", "v8ushort"],
  "b" => ["unsigned char", "v16uchar"]
);
my $path = "$ARGV[0].helper_xmm";
my $file_size = -s $ARGV[0];
open FDIN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
my $bytes;
my $br = read FDIN, $bytes, $file_size;
if ($br != $file_size) {
  die "Failed to read $ARGV[0]\n";
}
close FDIN;
my $str = unpack "a*", $bytes;
my @file_content = split(//, $str);
`rm -rf $path`;
`mkdir -p $path`;

# Regarding inband and outband mode:
# Inband mode is the simpler way to inline function: when the helper function
# does not call into QEMU runtime, and it does not modify any of register context,
# typically it returns a value as output, for example cc_compute_all/_c.
#
# Outband mode address above two factors, and it has to use tail call to help
# update register context
#

# Collect function definitions
my %funcs = ();
my %func_lookup = ();
my %func_lookup_map = ();
$func_lookup{'MAP'} = \%func_lookup_map;
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<FunctionDefinition/) {
    my @fields = split(/\$\$/, $line);
    my $nameStart;
    my $nameStop;
    my $bodyStart;
    my $bodyStop;
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
      $bodyStart = $f3[1];
      $bodyStop = $f4[1];
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
      $bodyStart = $f3[1];
      $bodyStop = $f4[1];
      $fullStart = $f1[1];
      $fullStop = $f4[1];
    } else {
      die "function definition info error!\n";
    }
    my %info = ();
    $info{'NAME_START'} = $nameStart;
    $info{'NAME_STOP'} = $nameStop;
    $info{'BODY_START'} = $bodyStart;
    $info{'BODY_STOP'} = $bodyStop;
    $info{'FULL_START'} = $fullStart;
    $info{'FULL_STOP'} = $fullStop;
    $info{'LOOKUP_START'} = $info{'BODY_START'};
    $info{'LOOKUP_STOP'} = $info{'BODY_STOP'};
    my $func_name = &GetText($nameStart, $nameStop);
    $func_name = &extract_func_name($func_name);
    $info{'NAME'} = $func_name;
    $info{'FUNC_FULL'} = &GetText($fullStart, $fullStop);
    my %calls = ();
    $info{'CALLS'} = \%calls;
    my %returns = ();
    $info{'RETURNS'} = \%returns;
    if (exists $funcs{$info{'NAME'}}) {
      print "Duplicated function definition $info{'NAME'}!\n";
      $info{'NAME'} = $info{'NAME'}."__DUPLICATED";
    }
    $funcs{$info{'NAME'}} = \%info;
    $func_lookup{'MAP'}->{$info{'LOOKUP_START'}} = \%info;
  }
}
close FD;
my @sorted_func_addr = sort {$a <=> $b} sort keys %{$func_lookup{'MAP'}};
$func_lookup{'SORTED_ADDR'} = \@sorted_func_addr;

# Collect call sites 
my %callsite_lookup = ();
my %callsite_lookup_map = ();
$callsite_lookup{'MAP'} = \%callsite_lookup_map;
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
    $info{'TYPE'} = "CALL";
    $info{'NAME_START'} = $f1[1];
    $info{'NAME_STOP'} = $f2[1];
    $info{'PAREN_START'} = $f3[1];
    $info{'PAREN_STOP'} = $f4[1];
    $info{'LOOKUP_START'} = $info{'PAREN_START'};
    $info{'LOOKUP_STOP'} = $info{'PAREN_STOP'};
    $info{'CALL_TARGET'} = &GetText($info{'NAME_START'}, $info{'NAME_STOP'});
    my $str = &GetText($info{'PAREN_START'}, $info{'PAREN_STOP'});
    $str =~ s/^\s*\(\s*//;
    $str =~ s/\s*\)\s*$//;
    @fields = split(/,/, $str);
    foreach my $i (0 .. $#fields) {
      $fields[$i] =~ s/^\s*//;
      $fields[$i] =~ s/\s*$//;
    }
    $info{'CALL_ARGUMENTS'} = \@fields;
    my ($func_idx, $ptr) = &lookup($info{'NAME_START'}, \%func_lookup);
    if ($func_idx != -1) {
      $info{'PARENT'} = $ptr->{'NAME'};
      $funcs{$ptr->{'NAME'}}->{'CALLS'}->{$info{'NAME_START'}} = \%info;
      $callsite_lookup{'MAP'}->{$info{'LOOKUP_START'}} = \%info;
    }
  }
}
close FD;
my @sorted_callsite_addr = sort {$a <=> $b} sort keys %{$callsite_lookup{'MAP'}};
$callsite_lookup{'SORTED_ADDR'} = \@sorted_callsite_addr;

# Mark functions by *_xmm
my %covered_funcs = ();
my %workset = ();
foreach my $f (keys %funcs) {
  if ($f =~ /_xmm$/) {
    $workset{$f} = 1;
    $covered_funcs{$f} = 1;
  }
}
while (keys %workset > 0) {
  my %tmpset = ();
  foreach my $f (keys %workset) {
    foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
      if (exists $funcs{$funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'}}) {
        if (not exists $covered_funcs{$funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'}}) {
          $tmpset{$funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'}} = 1;
          $covered_funcs{$funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'}} = 1;
        }
      }
    }
  }
  %workset = %tmpset;
}
foreach my $f (keys %covered_funcs) {
  $funcs{$f}->{'TOUCHED'} = 1;
}

# Handle return info and collect ENV
my %env_lookup = ();
my %env_lookup_map = ();
$env_lookup{'MAP'} = \%env_lookup_map;
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<RETURN_VOID>/) {
    my @fields = split(/\$\$/, $line);
    my %info = ();
    $info{'TYPE'} = "RETURN_VOID";
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    $info{'RETURN_START'} = $f1[1];
    $info{'RETURN_STOP'} = $f2[1];
    my $txt = &GetText($info{'RETURN_START'}, $info{'RETURN_STOP'});
    if ($txt ne "return;") {
      die "RETURN_VOID format error:$txt\n";
    }
    my ($func_idx, $ptr) = &lookup($info{'RETURN_START'}, \%func_lookup);
    if ($func_idx != -1) {
      $funcs{$ptr->{'NAME'}}->{'RETURNS'}->{$info{'RETURN_START'}} = \%info;
    }
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
    my ($func_idx, $ptr) = &lookup($info{'RETURN_START'}, \%func_lookup);
    if ($func_idx != -1) {
      $funcs{$ptr->{'NAME'}}->{'RETURNS'}->{$info{'RETURN_START'}} = \%info;
    }
  } elsif ($line =~ /^<ENV>/) {
    my @fields = split(/\$\$/, $line);
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my $start = $f1[1];
    my $stop = $f2[1];
    my ($func_idx, $func_ptr) = &lookup($start, \%func_lookup);
    if ($func_idx != -1) {
      if (exists $func_ptr->{'TOUCHED'}) {
        if ($file_content[$stop+1] ne "-") {
          my ($call_idx, $call_ptr) = &lookup($start, \%callsite_lookup);
          if ($call_idx == -1) {
            # Copy from x25
            #print "standalone ENV inside $func_ptr->{'NAME'}\n";
            die "" if ($file_content[$start-1] eq "." or $file_content[$start-1] eq ">");
            my $get_address = 0;
            if ($file_content[$start-1] eq "&") {
              $get_address = 1;
              $start = $start - 1;
            }
            my %env_info = ();
            $env_info{'TXT'} = &GetText($start, $stop);
            $env_info{'START'} = $start;
            $env_info{'STOP'} = $stop;
            $env_info{'LOOKUP_START'} = $env_info{'START'};
            $env_info{'LOOKUP_STOP'} = $env_info{'STOP'};
            $env_info{'GET_ADDRESS'} = $get_address;
            my @empty = ();
            $env_info{'DEF_SYM_INFO'} = \@empty;
            if (not exists $func_ptr->{'ENV'}) {
              my %info = ();
              $func_ptr->{'ENV'} = \%info;
            }
            $func_ptr->{'ENV'}->{$start} = \%env_info;
            $env_lookup{'MAP'}->{$env_info{'LOOKUP_START'}} = \%env_info;
          }
        } else {
          die "" if ($file_content[$start-1] eq "." or $file_content[$start-1] eq ">");
          die "" if $file_content[$stop+2] ne ">";
          my $get_address = 0;
          if ($file_content[$start-1] eq "&") {
            $get_address = 1;
            $start = $start - 1;
          }
          my @sym_info = ();
          my $pos = $stop + 3;
          while (1) {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol($pos, 0);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            if ($file_content[$sym_stop+1] eq "[") {
              $info{'IS_ARRAY'} = 1;
              my ($array_idx, $array_idx_start, $array_idx_stop) = &GetSymbol($sym_stop+2, 0);
              die "" if $file_content[$array_idx_stop+1] ne "]";
              $info{'ARRAY_IDX'} = $array_idx;
              $pos = $array_idx_stop + 2;
            } else {
              $pos = $sym_stop + 1;
            }
            push @sym_info, \%info;
            if ($file_content[$pos] eq ".") {
              $pos = $pos + 1;
            } else {
              last;
            }
          }
          $stop = $pos - 1;
          my %env_info = ();
          $env_info{'TXT'} = &GetText($start, $stop);
          $env_info{'START'} = $start;
          $env_info{'STOP'} = $stop;
          $env_info{'LOOKUP_START'} = $env_info{'START'};
          $env_info{'LOOKUP_STOP'} = $env_info{'STOP'};
          $env_info{'GET_ADDRESS'} = $get_address;
          $env_info{'DEF_SYM_INFO'} = \@sym_info;
          if ($file_content[$stop+1] eq " " and $file_content[$stop+2] eq "=" and $file_content[$stop+3] eq " ") {
            if ($sym_info[0]->{'SYM'} eq "cc_src" or $sym_info[0]->{'SYM'} eq "cc_dst" or $sym_info[0]->{'SYM'} eq "cc_op" or $sym_info[0]->{'SYM'} eq "regs" or $sym_info[0]->{'SYM'} eq "xmm_regs") {
              $env_info{'UPDATE_REGISTER_CONTEXT'} = 1;
              $func_ptr->{'UPDATE_REGISTER_CONTEXT'} = 1;
            }
          }
          if (not exists $func_ptr->{'ENV'}) {
            my %info = ();
            $func_ptr->{'ENV'} = \%info;
          }
          $func_ptr->{'ENV'}->{$start} = \%env_info;
          $env_lookup{'MAP'}->{$env_info{'LOOKUP_START'}} = \%env_info;
        }
      }
    }
  }
}
close FD;
my @sorted_env_addr = sort {$a <=> $b} sort keys %{$env_lookup{'MAP'}};
$env_lookup{'SORTED_ADDR'} = \@sorted_env_addr;

# Handle Vec* info
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<(Vec[BWLQ])>/) {
    my $code = $1;
    my @fields = split(/\$\$/, $line);
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my $start = $f1[1];
    my $stop = $f2[1];
    my ($func_idx, $func_ptr) = &lookup($start, \%func_lookup);
    if ($func_idx != -1) {
      if (exists $func_ptr->{'TOUCHED'}) {
        my ($env_idx, $env_ptr) = &lookup($start, \%env_lookup);
        if ($env_idx == -1) {
          die "" if $file_content[$stop+1] ne "[";
          my @vec_symbols = ();
          my %info = ();
          $info{'SYM'} = $code;
          $info{'IS_ARRAY'} = 1;
          my ($array_idx, $array_idx_start, $array_idx_stop) = &GetContentWithArrayBound($stop+2);
          $info{'ARRAY_IDX'} = $array_idx;
          die "" if ($file_content[$array_idx_stop+2] eq "." or $file_content[$array_idx_stop+2] eq "-");
          $stop = $array_idx_stop + 1;
          unshift @vec_symbols, \%info;
          if ($file_content[$start-1] eq ">") {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol($start-3, 1);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            unshift @vec_symbols, \%info;
            die "" if ($file_content[$sym_start-1] eq ">" or $file_content[$sym_start-1] eq ".");
            $start = $sym_start;
          } elsif ($file_content[$start-1] eq ".") {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol($start-2, 1);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            unshift @vec_symbols, \%info;
            die "" if ($file_content[$sym_start-1] eq ">" or $file_content[$sym_start-1] eq ".");
            $start = $sym_start;
          } else {
            die "";
          }
          $stop = $array_idx_stop + 1;
          my %vec_info = ();
          $vec_info{'TXT'} = &GetText($start, $stop);
          $vec_info{'START'} = $start;
          $vec_info{'STOP'} = $stop;
          $vec_info{'LOOKUP_START'} = $vec_info{'START'};
          $vec_info{'LOOKUP_STOP'} = $vec_info{'STOP'};
          if ($file_content[$start-1] eq "&") {
            $vec_info{'GET_ADDRESS'} = 1;
          } else {
            $vec_info{'GET_ADDRESS'} = 0;
          }
          $vec_info{'DEF_SYM_INFO'} = \@vec_symbols;
          if (not exists $func_ptr->{'VEC'}) {
            my %info = ();
            $func_ptr->{'VEC'} = \%info;
          }
          $func_ptr->{'VEC'}->{$start} = \%vec_info;
        }
      }
    }
  }
}
close FD;

# Collect background info (-function)
open FDIN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
my $current_pos = 0;
my $blank_info = "";
foreach my $a (@{$func_lookup{'SORTED_ADDR'}}) {
  my $txt = &GetText($current_pos, ($func_lookup{'MAP'}->{$a}->{'FULL_START'} - 1));
  $blank_info = $blank_info."\n".$txt;
  $current_pos = $func_lookup{'MAP'}->{$a}->{'FULL_STOP'} + 1;
}
my $total_size = -s $ARGV[0];
my $txt = &GetText($current_pos, ($total_size - 1));
$blank_info = $blank_info."\n".$txt;

my @qemuaot_gp_params = ("rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "src1", "dst", "op", "rip");
my %qemuaot_gp_params_map = (
  "rax" => "unsigned long",
  "rcx" => "unsigned long",
  "rdx" => "unsigned long",
  "rbx" => "unsigned long",
  "rsp" => "unsigned long",
  "rbp" => "unsigned long",
  "rsi" => "unsigned long",
  "rdi" => "unsigned long",
  "r8" => "unsigned long",
  "r9" => "unsigned long",
  "r10" => "unsigned long",
  "r11" => "unsigned long",
  "r12" => "unsigned long",
  "r13" => "unsigned long",
  "r14" => "unsigned long",
  "r15" => "unsigned long",
  "src1" => "unsigned long",
  "dst" => "unsigned long",
  "op" => "unsigned int",
  "rip" => "unsigned long",
);
my $qemuaot_vec_invoke = "XMM_PARAM_LIST";
my $qemuaot_vec_declare = "XMM_PARAM_DECLARE_COMMON";

sub lookup
{
  my ($loc, $lookup_info) = @_;
  my $low_idx = 0;
  my $high_idx = $#{$lookup_info->{'SORTED_ADDR'}};
  while (($high_idx - $low_idx) != 1) {
    if (!($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]}->{'LOOKUP_START'} < $loc and $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]}->{'LOOKUP_START'} > $loc)) {
      return -1;
    }
    my $middle_idx = int(($high_idx + $low_idx)/2);
    if ($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$middle_idx]}->{'LOOKUP_START'} < $loc) {
      $low_idx = $middle_idx;
    } else {
      $high_idx = $middle_idx;
    }
  }
  if (!($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]}->{'LOOKUP_START'} < $loc and $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]}->{'LOOKUP_STOP'} > $loc)) {
    return -1;
  }
  return ($low_idx, $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]});
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
  my ($posStart, $posEnd) = @_;
  my @sub_array = @file_content[$posStart..$posEnd];
  my $ret = join("", @sub_array);
  return $ret;
}

sub GetSymbol
{
  my ($sym_start, $reverse) = @_;
  my $sym_stop = $sym_start;
  while (("a" le $file_content[$sym_stop] and $file_content[$sym_stop] le "z") or
        ("A" le $file_content[$sym_stop] and $file_content[$sym_stop] le "Z") or
        ("0" le $file_content[$sym_stop] and $file_content[$sym_stop] le "9") or
        $file_content[$sym_stop] eq "_") {
    if ($reverse) {
      $sym_stop = $sym_stop - 1;
    } else {
      $sym_stop = $sym_stop + 1;
    }
  }
  if ($reverse) {
    $sym_stop = $sym_stop + 1;
  } else {
    $sym_stop = $sym_stop - 1;
  }
  if ($reverse) {
    my $tmp = $sym_start;
    $sym_start = $sym_stop;
    $sym_stop = $tmp;
  }
  if ($sym_start > $sym_stop) {
    die "Symbol not found at $sym_start!\n";
  }
  my @sub_array = @file_content[$sym_start..$sym_stop];
  my $sym = join("", @sub_array);
  return ($sym, $sym_start, $sym_stop);
}

sub GetContentWithArrayBound
{
  my ($sym_start) = @_;
  my $sym_stop = $sym_start;
  my $cnt = 1;
  while (1) {
    if ($file_content[$sym_stop] eq "[") {
      $cnt = $cnt + 1;
    } elsif ($file_content[$sym_stop] eq "]") {
      $cnt = $cnt - 1;
    }
    if ($cnt == 0) {
      last;
    }
    $sym_stop = $sym_stop + 1;
  }
  $sym_stop = $sym_stop - 1;
  my @sub_array = @file_content[$sym_start..$sym_stop];
  my $sym = join("", @sub_array);
  return ($sym, $sym_start, $sym_stop);
}

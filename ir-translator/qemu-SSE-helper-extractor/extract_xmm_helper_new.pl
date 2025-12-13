#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use File::Basename;
use IO::Select;
use Cwd 'abs_path';

if ($#ARGV < 1) {
  print "Usage: ./script <antlr-in> <antlr-out>\n";
  exit 1;
}

my %VecCodeToCType = (
  "VecQ" => "v2ulong",
  "VecL" => "v4uint",
  "VecW" => "v8ushort",
  "VecB" => "v16uchar"
);
my %VecSymbolToCType = (
  "_q_ZMMReg" => "v2ulong",
  "_l_ZMMReg" => "v4uint",
  "_w_ZMMReg" => "v8ushort",
  "_b_ZMMReg" => "v16uchar"
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
my $global_func_idx = 0;
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
    $info{'FUNC_FULL'} = &GetText($bodyStart, $bodyStop);
    $info{'FUNC_IDX'} = $global_func_idx;
    $global_func_idx = $global_func_idx + 1;
    my %calls = ();
    $info{'CALLS'} = \%calls;
    my %vec_assign = ();
    $info{'VEC_ASSIGN'} = \%vec_assign;
    my %returns = ();
    $info{'RETURNS'} = \%returns;
    if (exists $funcs{$info{'NAME'}}) {
      #print "Duplicated function definition $info{'NAME'}!\n";
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
    if (&FuncNameIsForeign($info{'CALL_TARGET'})) {
      $info{'IS_FOREIGN'} = 1;
    }
    my $str = &GetText($info{'PAREN_START'} + 1, $info{'PAREN_STOP'} - 1);
    my ($args, $ranges) = &ExtractCallArguments($str, $info{'PAREN_START'} + 1);
    $info{'CALL_ARGUMENTS'} = $args;
    $info{'CALL_ARGUMENT_RANGES'} = $ranges;
    my ($func_idx, $ptr) = &lookup($info{'NAME_START'}, \%func_lookup);
    if ($func_idx != -1) {
      #print "$ptr->{'NAME'} calls $info{'CALL_TARGET'}\n";
      #foreach my $a (@{$info{'CALL_ARGUMENTS'}}) {
      #  print "$a\n";
      #}
      $info{'PARENT'} = $ptr->{'NAME'};
      if (exists $info{'IS_FOREIGN'}) {
        $funcs{$ptr->{'NAME'}}->{'IS_FOREIGN'} = 1;
      }
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
  my ($head, $scalar_args, $vector_args, $pure_arg_info, $ret128_info, $env_type) = &parse_func_head($funcs{$f});
  $funcs{$f}->{'HEAD'} = $head;
  $funcs{$f}->{'PURE_ARG_INFO'} = $pure_arg_info;
  $funcs{$f}->{'SCALAR_ARGS'} = $scalar_args;
  $funcs{$f}->{'VECTOR_ARGS'} = $vector_args;
  $funcs{$f}->{'ENV_TYPE'} = $env_type;
  if (@{$vector_args} > 0) {
    $funcs{$f}->{'DO_EXPAND'} = 1;
    if (not exists $funcs{$f}->{'EXPAND_FACTORS'}) {
      my @array = ();
      $funcs{$f}->{'EXPAND_FACTORS'} = \@array;
    }
    foreach my $e (@{$vector_args}) {
      push @{$funcs{$f}->{'EXPAND_FACTORS'}}, $e->{'VAR_NAME'};
    }
  } else {
    $funcs{$f}->{'DO_EXPAND'} = 0;
  }
  $funcs{$f}->{'128'} = $ret128_info;
}

# Collect VecType info(ZMMReg), to detect tmp vector variable and do the patch.
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<VecType>/) {
    my @fields = split(/\$\$/, $line);
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my $start = $f1[1];
    my $stop = $f2[1];
    my ($func_idx, $func_ptr) = &lookup($start, \%func_lookup);
    if ($func_idx != -1) {
      my %info = ();
      $info{'START'} = $start;
      my $current_pos = $stop + 1;
      while (&IsValidSymbolStart($file_content[$current_pos]) == 0) {
        die "" if $file_content[$current_pos] eq "*";
        $current_pos = $current_pos + 1;
      }
      my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@file_content, $current_pos, 0);
      $info{'SYM'} = $sym;
      $current_pos = $sym_stop + 1;
      while ($file_content[$current_pos] =~ /\s/) {
        $current_pos = $current_pos + 1;
      }
      die "" if $file_content[$current_pos] ne "=";
      $current_pos = $current_pos + 1;
      while ($file_content[$current_pos] =~ /\s/) {
        $current_pos = $current_pos + 1;
      }
      die "" if $file_content[$current_pos] ne "*";
      $current_pos = $current_pos + 1;
      while ($file_content[$current_pos] =~ /\s/) {
        $current_pos = $current_pos + 1;
      }
      ($sym, $sym_start, $sym_stop) = &GetSymbol(\@file_content, $current_pos, 0);
      my $vec_arg_idx = &get_vec_arg_idx($func_ptr, $sym);
      die "" if $vec_arg_idx == -1;
      die "" if $file_content[$sym_stop+1] ne ";";
      $info{'VEC_ARG_IDX'} = $vec_arg_idx;
      $info{'STOP'} = $sym_stop;
      if (not exists $func_ptr->{'VEC_VAR'}) {
        my %vec_var_info = ();
        $func_ptr->{'VEC_VAR'} = \%vec_var_info;
      }
      $func_ptr->{'VEC_VAR'}->{$info{'START'}} = \%info;
    }
  }
}
close FD;

# Patch detail call info used by vector expansion
foreach my $f (keys %funcs) {
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $i = $funcs{$f}->{'CALLS'}->{$e};
    my @scalars = ();
    my @scalar_ranges = ();
    my @vectors = ();
    my $callee = $funcs{$i->{'CALL_TARGET'}};
    foreach my $e (@{$callee->{'SCALAR_ARGS'}}) {
      push @scalars, $i->{'CALL_ARGUMENTS'}->[$e->{'IDX'}];
      push @scalar_ranges, $i->{'CALL_ARGUMENT_RANGES'}->[$e->{'IDX'}];
    }
    foreach my $e (@{$callee->{'VECTOR_ARGS'}}) {
      push @vectors, $i->{'CALL_ARGUMENTS'}->[$e->{'IDX'}];
    }
    $i->{'SCALAR_CALL_ARGS'} = \@scalars;
    $i->{'SCALAR_CALL_ARG_RANGES'} = \@scalar_ranges;
    $i->{'VECTOR_CALL_ARGS'} = \@vectors;
    my $caller = $funcs{$i->{'PARENT'}};
    my @caller_arg_vectors = ();
    foreach my $v (@vectors) {
      my $caller_idx = &get_vec_arg_idx($caller, $v);
      die "Check $caller->{'NAME'} vector call $callee->{'NAME'}\n" if ($caller_idx == -1);
      push @caller_arg_vectors, $caller_idx;
    }
    $i->{'CALLER_ARG_VECTORS'} = \@caller_arg_vectors;
  }
}
close FD;

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
            $func_ptr->{'DO_DEFINE_ENV'} = 1;
            die "" if $func_ptr->{'ENV_TYPE'} eq "NA";
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
            $func_ptr->{'DO_DEFINE_ENV'} = 1;
            die "" if $func_ptr->{'ENV_TYPE'} eq "NA";
          }
          my @sym_info = ();
          my $pos = $stop + 3;
          while (1) {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@file_content, $pos, 0);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            if ($file_content[$sym_stop+1] eq "[") {
              $info{'IS_ARRAY'} = 1;
              my ($array_idx, $array_idx_start, $array_idx_stop) = &GetSymbol(\@file_content, $sym_stop+2, 0);
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
          if ($sym_info[0]->{'SYM'} eq "regs") {
            die "" if $sym_info[0]->{'IS_ARRAY'} == 0;
            foreach my $si (@{$func_ptr->{'SCALAR_ARGS'}}) {
              if ($sym_info[0]->{'ARRAY_IDX'} eq $si->{'VAR_NAME'}) {
                $func_ptr->{'DO_EXPAND'} = 1;
                if (not exists $func_ptr->{'EXPAND_FACTORS'}) {
                  my @array = ();
                  $func_ptr->{'EXPAND_FACTORS'} = \@array;
                  my %info_map = ();
                  $func_ptr->{'EXPAND_FACTORS_MAP'} = \%info_map;
                }
                if (not exists $func_ptr->{'EXPAND_FACTORS_MAP'}->{$si->{'VAR_NAME'}}) {
                  push @{$func_ptr->{'EXPAND_FACTORS'}}, $si->{'VAR_NAME'};
                  $func_ptr->{'EXPAND_FACTORS_MAP'}->{$si->{'VAR_NAME'}} = 1;
                }
              }
            }
          }
          if (not ($sym_info[0]->{'SYM'} eq "cc_src" or $sym_info[0]->{'SYM'} eq "cc_dst" or $sym_info[0]->{'SYM'} eq "cc_op" or $sym_info[0]->{'SYM'} eq "regs" or $sym_info[0]->{'SYM'} eq "xmm_regs")) {
            $func_ptr->{'DO_DEFINE_ENV'} = 1;
            die "" if $func_ptr->{'ENV_TYPE'} eq "NA";
          }
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
          unshift @vec_symbols, \%info;
          if ($file_content[$start-1] eq ">") {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@file_content, $start-3, 1);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            unshift @vec_symbols, \%info;
            die "" if ($file_content[$sym_start-1] eq ">" or $file_content[$sym_start-1] eq ".");
            $start = $sym_start;
          } elsif ($file_content[$start-1] eq ".") {
            my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@file_content, $start-2, 1);
            my %info = ();
            $info{'SYM'} = $sym;
            $info{'IS_ARRAY'} = 0;
            unshift @vec_symbols, \%info;
            die "" if ($file_content[$sym_start-1] eq ">" or $file_content[$sym_start-1] eq ".");
            $start = $sym_start;
          } else {
            die "";
          }
          # Parse vec_symbols into argument info or var info
          my %vec_info = ();
          $vec_info{'TXT'} = &GetText($start, $stop);
          $vec_info{'START'} = $start;
          $vec_info{'STOP'} = $stop;
          $vec_info{'LOOKUP_START'} = $vec_info{'START'};
          $vec_info{'LOOKUP_STOP'} = $vec_info{'STOP'};
          $vec_info{'TYPE'} = $vec_symbols[$#vec_symbols]->{'SYM'};
          die "" if $file_content[$start-1] eq "&";
          $vec_info{'DEF_SYM_INFO'} = \@vec_symbols;
          my $vec_param_idx = &get_vec_arg_idx($func_ptr, $vec_symbols[0]->{'SYM'});
          my $skip_vec = 0;
          if ($vec_param_idx != -1) {
            $vec_info{'FROM_PARAM'} = 1;
            $vec_info{'VAR'} = $vec_param_idx;
            if ($file_content[$array_idx_stop+2] eq " " and $file_content[$array_idx_stop+3] eq "=" and $file_content[$array_idx_stop+4] eq " ") {
              # Collect vector assignment info
              my %vec_assign = ();
              $vec_assign{'VEC_INFO'} = \%vec_info;
              $vec_assign{'ASSIGN_POS'} = $array_idx_stop+3;
              my $semi_pos = $vec_assign{'ASSIGN_POS'};
              while ($file_content[$semi_pos] ne ";") {
                $semi_pos = $semi_pos + 1;
              }
              $vec_assign{'SEMI_POS'} = $semi_pos;
              $func_ptr->{'VEC_ASSIGN'}->{$start} = \%vec_assign;
              $skip_vec = 1;
            }
          } else {
            $vec_info{'FROM_PARAM'} = 0;
            $vec_info{'VAR'} = $vec_symbols[0]->{'SYM'};
          }
          if ($skip_vec == 0) {
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
#my $qemuaot_vec_invoke = "XMM_PARAM_LIST";
#my $qemuaot_vec_declare = "XMM_PARAM_DECLARE_COMMON";
my $qemuaot_vec_invoke = "xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h";
my $qemuaot_vec_declare = "v2ulong xmm0, v2ulong ymm0_h, v2ulong xmm1, v2ulong ymm1_h, v2ulong xmm2, v2ulong ymm2_h, v2ulong xmm3, v2ulong ymm3_h, v2ulong xmm4, v2ulong ymm4_h, v2ulong xmm5, v2ulong ymm5_h, v2ulong xmm6, v2ulong ymm6_h, v2ulong xmm7, v2ulong ymm7_h, v2ulong xmm8, v2ulong ymm8_h, v2ulong xmm9, v2ulong ymm9_h, v2ulong xmm10, v2ulong ymm10_h, v2ulong xmm11, v2ulong ymm11_h, v2ulong xmm12, v2ulong ymm12_h, v2ulong xmm13, v2ulong ymm13_h, v2ulong xmm14, v2ulong ymm14_h";
my %env_reg_idx_map = (
  "R_EAX" => "rax",
  "R_ECX" => "rcx",
  "R_EDX" => "rdx",
  "R_EBX" => "rbx",
  "R_ESP" => "rsp",
  "R_EBP" => "rbp",
  "R_ESI" => "rsi",
  "R_EDI" => "rdi",
  "R_R8" => "r8",
  "R_R9" => "r9",
  "R_R10" => "r10",
  "R_R11" => "r11",
  "R_R12" => "r12",
  "R_R13" => "r13",
  "R_R14" => "r14",
  "R_R15" => "r15"
);
my %env_xmmregs_idx_map = (
  "0" => "xmm0",
  "1" => "xmm1",
  "2" => "xmm2",
  "3" => "xmm3",
  "4" => "xmm4",
  "5" => "xmm5",
  "6" => "xmm6",
  "7" => "xmm7",
  "8" => "xmm8",
  "9" => "xmm9",
  "10" => "xmm10",
  "11" => "xmm11",
  "12" => "xmm12",
  "13" => "xmm13",
  "14" => "xmm14",
  "15" => "xmm15"
);

foreach my $f (keys %funcs) {
  if (not ($f =~ /^helper_/ and $f =~ /_xmm$/)) {
    next;
  }
  my $has_foreign_call = 0;
  if (exists $funcs{$f}->{'IS_FOREIGN'}) {
    $has_foreign_call = 1;
  }
  my $update_register_context = 0;
  if (exists $funcs{$f}->{'UPDATE_REGISTER_CONTEXT'}) {
    $update_register_context = 1;
  }
  # Collect dependent functions
  my @sub_call_stack = ();
  my %defined_func = ();
  # Assume no infinite recursive calls for path_info
  my %path_info = ();
  my @label_info = ();
  $path_info{'ROOT'} = \@label_info;
  $defined_func{$f} = \%path_info;
  my %func_call_path = ();
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $call_target = $funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'};
    if (exists $funcs{$call_target}) {
      if (not exists $defined_func{$call_target}) {
        push @sub_call_stack, $call_target;
        my %p_info = ();
        $defined_func{$call_target} = \%p_info;
        if (exists $funcs{$call_target}->{'IS_FOREIGN'}) {
          $has_foreign_call = 1;
        }
        if (exists $funcs{$call_target}->{'UPDATE_REGISTER_CONTEXT'}) {
          $update_register_context = 1;
        }
      }
      foreach my $pi (keys %{$defined_func{$f}}) {
        my $current_pi = $pi."_".$f."_loc$e";
        my @label_info = ();
        foreach my $elem (@{$defined_func{$f}->{$pi}}) {
          push @label_info, $elem;
        }
        my %entry_info = ();
        $entry_info{'FUNC'} = $f;
        $entry_info{'LOC'} = $e;
        push @label_info, \%entry_info;
        $defined_func{$call_target}->{$current_pi} = \@label_info;
        # FIXME: simplify duplicated mark actions
        if (exists $funcs{$call_target}->{'IS_FOREIGN'}) {
          foreach my $i (@label_info) {
            $funcs{$i->{'FUNC'}}->{'IS_FOREIGN'} = 1;
          }
        }
      }
    }
  }
  while (@sub_call_stack > 0) {
    my @new_call_stack = ();
    foreach my $c (@sub_call_stack) {
      foreach my $e (keys %{$funcs{$c}->{'CALLS'}}) {
        my $call_target = $funcs{$c}->{'CALLS'}->{$e}->{'CALL_TARGET'};
        if (exists $funcs{$call_target}) {
          if (not exists $defined_func{$call_target}) {
            push @new_call_stack, $call_target;
            my %p_info = ();
            $defined_func{$call_target} = \%p_info;
            if (exists $funcs{$call_target}->{'IS_FOREIGN'}) {
              $has_foreign_call = 1;
            }
            if (exists $funcs{$call_target}->{'UPDATE_REGISTER_CONTEXT'}) {
              $update_register_context = 1;
            }
          }
          foreach my $pi (keys %{$defined_func{$c}}) {
            my $current_pi = $pi."_".$c."_loc$e";
            my @label_info = ();
            foreach my $elem (@{$defined_func{$c}->{$pi}}) {
              push @label_info, $elem;
            }
            my %entry_info = ();
            $entry_info{'FUNC'} = $c;
            $entry_info{'LOC'} = $e;
            push @label_info, \%entry_info;
            $defined_func{$call_target}->{$current_pi} = \@label_info;
            # FIXME: simplify duplicated mark actions
            if (exists $funcs{$call_target}->{'IS_FOREIGN'}) {
              foreach my $i (@label_info) {
                $funcs{$i->{'FUNC'}}->{'IS_FOREIGN'} = 1;
              }
            }
          }
        }
      }
    }
    @sub_call_stack = @new_call_stack;
  }

  print "$f $has_foreign_call $update_register_context\n";

  # Generate function
  open OUT, "> $path/$f.c" or die "Cannot open $path/$f.c for write!\n";
  print OUT "$blank_info\n\n";
  print OUT<<EOF;

// QEMU_HELPER_BEGIN
typedef unsigned short __attribute__((__vector_size__(16))) v8ushort;
typedef unsigned char __attribute__((__vector_size__(16))) v16uchar;
typedef unsigned int __attribute__((__vector_size__(16))) v4uint;
typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;

EOF
  my %order_to_func = ();
  foreach my $sf (keys %defined_func) {
    $order_to_func{$funcs{$sf}->{'FUNC_IDX'}} = $sf;
  }
  my @sorted_funcs = sort {$a <=> $b} keys %order_to_func;
  foreach my $s (@sorted_funcs) {
    my $func_name = $order_to_func{$s};
    my $new_func = &gen_replicated_func($func_name, \%defined_func);
    print OUT "$new_func\n\n";
  }

  close OUT;
}

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
  my ($str_array, $sym_start, $reverse) = @_;
  select()->flush();
  if ($reverse == 0) {
    while ($str_array->[$sym_start] eq "(") {
      $sym_start = $sym_start + 1;
    }
  } else {
    while ($str_array->[$sym_start] eq ")") {
      $sym_start = $sym_start - 1;
    }
  }
  my $sym_stop = $sym_start;
  die "" if (not($sym_stop >= 0 and $sym_stop <= $#{$str_array}));
  while (("a" le $str_array->[$sym_stop] and $str_array->[$sym_stop] le "z") or
        ("A" le $str_array->[$sym_stop] and $str_array->[$sym_stop] le "Z") or
        ("0" le $str_array->[$sym_stop] and $str_array->[$sym_stop] le "9") or
        $str_array->[$sym_stop] eq "_") {
    if ($reverse) {
      $sym_stop = $sym_stop - 1;
    } else {
      $sym_stop = $sym_stop + 1;
    }
    if ($sym_stop < 0 or $sym_stop > $#{$str_array}) {
      last;
    }
  }
  if ($reverse) {
    if ($sym_stop < $#{$str_array}) {
      $sym_stop = $sym_stop + 1;
    }
  } else {
    if ($sym_stop > 0) {
      $sym_stop = $sym_stop - 1;
    }
  }
  if ($reverse) {
    my $tmp = $sym_start;
    $sym_start = $sym_stop;
    $sym_stop = $tmp;
  }
  if ($sym_start > $sym_stop) {
    my $debug_info = join("", @{$str_array});
    die "Symbol not found at $debug_info:$sym_start-$sym_stop END:$#{$str_array}!\n";
  }
  my @sub_array = @{$str_array}[$sym_start..$sym_stop];
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

sub parse_func_head
{
  my ($func) = @_;
  my $env_type = "NA";
  my $str = &GetText($func->{'FULL_START'}, $func->{'NAME_STOP'}, $ARGV[0]);
  $str = &mov_tail_attribute_to_head($str);
  my @chars = split(//, $str);
  my $idx = $#chars;
  my $paren_cnt = 0;
  while ($idx >= 0) {
    if ($chars[$idx] eq ")") {
      $paren_cnt = $paren_cnt + 1;
    } elsif ($chars[$idx] eq "(") {
      $paren_cnt = $paren_cnt - 1;
      if ($paren_cnt == 0) {
        last;
      }
    }
    $idx = $idx - 1;
  }
  my @slice_head = @chars[0..($idx-1)];
  my @slice_tail = @chars[$idx..$#chars];
  my $head = join("", @slice_head);
  my $head_copy = $head;
  if (not $head_copy =~ /__attribute__\(\(always_inline\)\)/) {
    $head_copy = "__attribute__((always_inline,weak)) ".$head_copy;
  } elsif (not $head_copy =~ /__attribute__\(\(weak\)\)/) {
    $head_copy = "__attribute__((weak)) ".$head_copy;
  }
  if (not ($func->{'NAME'} =~ /^helper_/ and $func->{'NAME'} =~ /_xmm$/)) {
    if ($head_copy =~ /static\s+/) {
      $head_copy =~ s/static\s+//;
    }
  } else {
    $head_copy =~ s/$func->{'NAME'}/HELPER_ENTRY/;
  }
  $head =~ s/\n/ /g;
  $head =~ s/\s*$//;
  @slice_head = split(//, $head);
  my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@slice_head, $#slice_head, 1);
  $sym_start = $sym_start - 1;
  while ($slice_head[$sym_start] eq " " or $slice_head[$sym_start] eq "*") {
    $sym_start = $sym_start - 1;
  }
  my @sub_slice = @slice_head[0..$sym_start];
  $head = join("", @sub_slice);
  if ($head =~ /\)$/) {
    $head = &mov_tail_attribute_to_head($head);
  }
  @slice_head = split(//, $head);
  $sym_start = $#slice_head;
  while ($slice_head[$sym_start] eq " " or $slice_head[$sym_start] eq "*") {
    $sym_start = $sym_start - 1;
  }
  ($sym, $sym_start, $sym_stop) = &GetSymbol(\@slice_head, $sym_start, 1);
  my %ret128_info = ();
  if ($sym =~ /128/) {
    $ret128_info{'RETURN128'} = 1;
    $ret128_info{'TYPE_NAME'} = $sym;
  } else {
    $ret128_info{'RETURN128'} = 0;
    $ret128_info{'TYPE_NAME'} = "";
  }
  my $tail = join("", @slice_tail);
  $tail =~ s/^\(\s*//;
  $tail =~ s/\s*\)\s*$//;
  $tail =~ s/,\s*\.\.\.$//;
  $tail =~ s/\s*$//;
  my $pure_arg_info = $tail;
  if ($tail ne "void") {
    my @fields = split(/,/, $tail);
    my @scalar = ();
    my @vector = ();
    foreach my $i (0 .. $#fields) {
      $fields[$i] =~ s/^\s*//;
      $fields[$i] =~ s/\s*$//;
      my @sub_fields = split(/\s+/, $fields[$i]);
      my %info = ();
      die "$str" if @sub_fields == 1;
      my $type = "";
      foreach my $idx (0 .. $#sub_fields-1) {
        if ($type eq "") {
          $type = $sub_fields[$idx];
        } else {
          $type = $type." ".$sub_fields[$idx];
        }
      }
      my $var = $sub_fields[$#sub_fields];
      if ($var =~ /^([\*]+)/) {
        $type = $type." ".$1;
        $var =~ s/^[\*]+//;
      }
      $var =~ s/\s*$//;
      $var =~ s/^\s*//;
      $info{'TYPE'} = $type;
      $info{'VAR_NAME'} = $var;
      $info{'IDX'} = $i;
      # Drop env from arguments
      if ($var eq "env") {
        $env_type = $type;
        next;
      }
      if ($type eq "ZMMReg *") {
        push @vector, \%info;
      } else {
        push @scalar, \%info;
      }
    }
    return ($head_copy, \@scalar, \@vector, $pure_arg_info, \%ret128_info, $env_type);
  } else {
    my @empty = ();
    return ($head_copy, \@empty, \@empty, $pure_arg_info, \%ret128_info, $env_type);
  }
}

sub mov_tail_attribute_to_head
{
  my ($str) = @_;
  while (1) {
    my @chars = split(//, $str);
    my $idx = $#chars;
    my $paren_cnt = 0;
    while ($idx >= 0) {
      if ($chars[$idx] eq ")") {
        $paren_cnt = $paren_cnt + 1;
      } elsif ($chars[$idx] eq "(") {
        $paren_cnt = $paren_cnt - 1;
        if ($paren_cnt == 0) {
          last;
        }
      }
      $idx = $idx - 1;
    }
    $idx = $idx - 1;
    while ($chars[$idx] eq " ") {
      $idx = $idx - 1;
    }
    my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@chars, $idx, 1);
    if (not $sym =~ /_*attribute_*/) {
      last;
    } else {
      my @head = @chars[0..($sym_start-1)];
      my @tail = @chars[$sym_start..$#chars];
      my $head_str = join("", @head);
      $head_str =~ s/\s*$//;
      my $tail_str = join("", @tail);
      $str = $tail_str." ".$head_str;
      if (not $str =~ /\)$/) {
        last;
      }
    }
  }
  return $str;
}

sub get_vec_arg_idx
{
  my ($func_ptr, $vec_sym) = @_;
  foreach my $idx (0 .. $#{$func_ptr->{'VECTOR_ARGS'}}) {
    if ($func_ptr->{'VECTOR_ARGS'}->[$idx]->{'VAR_NAME'} eq $vec_sym) {
      return $idx;
    }
  }
  return -1;
}

sub get_scalar_arg_idx
{
  my ($func_ptr, $scalar_sym) = @_;
  foreach my $idx (0 .. $#{$func_ptr->{'SCALAR_ARGS'}}) {
    if ($func_ptr->{'SCALAR_ARGS'}->[$idx]->{'VAR_NAME'} eq $scalar_sym) {
      return $idx;
    }
  }
  return -1;
}

sub gen_replicated_func
{
  my ($target_func, $func_replicate_info) = @_;
  my $new_func = "";
  if ($funcs{$target_func}->{'DO_EXPAND'} == 0) {
    my $new_head = $funcs{$target_func}->{'HEAD'};
    my $args = &collect_func_args($funcs{$target_func});
    my $current_func = $new_head."($args)\n";
    my %empty = ();
    my $new_func_body = &get_func_body($funcs{$target_func}, "", \%empty);
    $current_func = $current_func.$new_func_body."\n\n";
    $new_func = $new_func.$current_func;
  } else {
    my %pi_info = ();
    foreach my $pi (keys %{$func_replicate_info->{$target_func}}) {
      my @input_arg_vec_idx = ();
      $pi_info{$pi} = \@input_arg_vec_idx;
      if ($pi eq "ROOT") {
        foreach my $idx (0 .. $#{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
          push @{$pi_info{$pi}}, $idx;
        }
      } else {
        # Figure out vector argument mapping
        foreach my $i (@{$func_replicate_info->{$target_func}->{$pi}}) {
          die "" if not exists $funcs{$i->{'FUNC'}};
          die "" if not exists $funcs{$i->{'FUNC'}}->{'CALLS'}->{$i->{'LOC'}};
          if (@{$pi_info{$pi}} == 0) {
            foreach my $vi (0 .. $#{$funcs{$func_replicate_info->{$target_func}->{$pi}->[0]->{'FUNC'}}->{'VECTOR_ARGS'}}) {
              push @{$pi_info{$pi}}, $vi;
            }
          }
          if (@{$funcs{$i->{'FUNC'}}->{'CALLS'}->{$i->{'LOC'}}->{'CALLER_ARG_VECTORS'}} == 0) {
            last;
          }
          my $target_func = $funcs{$i->{'FUNC'}}->{'CALLS'}->{$i->{'LOC'}}->{'CALL_TARGET'};
          my @target_args = ();
          foreach my $ti (@{$funcs{$i->{'FUNC'}}->{'CALLS'}->{$i->{'LOC'}}->{'CALLER_ARG_VECTORS'}}) {
            die "" if ($ti < 0 or $ti > $#{$pi_info{$pi}});
            push @target_args, $pi_info{$pi}->[$ti];
          }
          die "" if @target_args == 0;
          $pi_info{$pi} = \@target_args;
        }
      }
      die "" if $#{$pi_info{$pi}} == -1;
      my $new_head = $funcs{$target_func}->{'HEAD'};
      #die "" if not $new_head =~ /$funcs{$target_func}->{'NAME'}$/;
      if ($pi ne "ROOT") {
        $new_head = $new_head."_".$pi;
      }
      my $args = &collect_func_args($funcs{$target_func});
      my $current_func = $new_head."($args)\n";
      # Define arguments
      my %macro_def = ();
      foreach my $var (@{$funcs{$target_func}->{'EXPAND_FACTORS'}}) {
        my $vec_idx = &get_vec_arg_idx($funcs{$target_func}, $var);
        if ($vec_idx != -1) {
          $current_func = $current_func."#define $var VEC$pi_info{$pi}->[$vec_idx]\n";
        } else {
          my $scalar_idx = &get_scalar_arg_idx($funcs{$target_func}, $var);
          die "" if $scalar_idx == -1;
          die "" if $#{$func_replicate_info->{$target_func}->{$pi}} == -1;
          my $in = $func_replicate_info->{$target_func}->{$pi}->[$#{$func_replicate_info->{$target_func}->{$pi}}];
          $current_func = $current_func."#define $var $funcs{$in->{'FUNC'}}->{'CALLS'}->{$in->{'LOC'}}->{'SCALAR_CALL_ARGS'}->[$scalar_idx]\n";
          $macro_def{$var} = $funcs{$in->{'FUNC'}}->{'CALLS'}->{$in->{'LOC'}}->{'SCALAR_CALL_ARGS'}->[$scalar_idx];
        }
      }
      my $new_func_body = &get_func_body($funcs{$target_func}, $pi, \%macro_def);
      $current_func = $current_func.$new_func_body."\n";
      $new_func = $new_func.$current_func;
      # Un-define arguments
      foreach my $var (@{$funcs{$target_func}->{'EXPAND_FACTORS'}}) {
        $new_func = $new_func."#undef $var\n";
      }
      $new_func = $new_func."\n";
    }
  }
  return $new_func;
}

sub get_func_body
{
  my ($func_ptr, $pi, $md) = @_;
  my %events = ();
  foreach my $e (keys %{$func_ptr->{'CALLS'}}) {
    $events{$e} = 1;
  }
  foreach my $e (keys %{$func_ptr->{'VEC'}}) {
    $events{$e} = 1;
  }
  foreach my $e (keys %{$func_ptr->{'VEC_VAR'}}) {
    $events{$e} = 1;
  }
  foreach my $e (keys %{$func_ptr->{'ENV'}}) {
    $events{$e} = 1;
  }
  foreach my $e (keys %{$func_ptr->{'VEC_ASSIGN'}}) {
    $events{$e} = 1;
  }
  my @sorted_events = sort {$a <=> $b} keys %events;
  my $current_pos;
  my $body = "";
  if (exists $func_ptr->{'DO_DEFINE_ENV'}) {
    $body = "{\n";
    $body = $body."   $func_ptr->{'ENV_TYPE'}env;\n";
    # FIXME: cross platform
    $body = $body."   asm volatile (\"mov %0, x25\" : \"=r\" (env) : :);\n";
    $current_pos = $func_ptr->{'BODY_START'} + 1;
  } else {
    $current_pos = $func_ptr->{'BODY_START'};
  }
  foreach my $e (@sorted_events) {
    if ($e < $current_pos) {
      next;
    }
    die "" if $e == $current_pos;
    my $txt = &GetText($current_pos, ($e - 1));
    $body = $body.$txt;
    if (exists $func_ptr->{'CALLS'}->{$e}) {
      my $call_target = $func_ptr->{'CALLS'}->{$e}->{'CALL_TARGET'};
      if (not exists $funcs{$call_target}) {
        $current_pos = $e;
      } else {
        my $call_txt = &update_func_call($func_ptr, $e, $funcs{$call_target}, $pi);
        $body = $body.$call_txt;
        $current_pos = $func_ptr->{'CALLS'}->{$e}->{'PAREN_STOP'} + 1;
      }
    } elsif (exists $func_ptr->{'VEC'}->{$e}) {
      if ($func_ptr->{'VEC'}->{$e}->{'FROM_PARAM'}) {
        $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$e}->{'TYPE'}})$func_ptr->{'VECTOR_ARGS'}->[$func_ptr->{'VEC'}->{$e}->{'VAR'}]->{'VAR_NAME'})";
        $current_pos = $func_ptr->{'VEC'}->{$e}->{'STOP'} + 1;
      } else {
        $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$e}->{'TYPE'}})$func_ptr->{'VEC'}->{$e}->{'VAR'})";
        $current_pos = $func_ptr->{'VEC'}->{$e}->{'STOP'} + 1;
      }
    } elsif (exists $func_ptr->{'VEC_VAR'}->{$e}) {
      my $entry = $func_ptr->{'VEC_VAR'}->{$e};
      $body = $body."v2ulong ".$entry->{'SYM'}." = ".$func_ptr->{'VECTOR_ARGS'}->[$entry->{'VEC_ARG_IDX'}]->{'VAR_NAME'};
      $current_pos = $entry->{'STOP'} + 1;
    } elsif (exists $func_ptr->{'ENV'}->{$e}) {
      my $entry = $func_ptr->{'ENV'}->{$e};
      if ($entry->{'GET_ADDRESS'}) {
        $current_pos = $e;
      } else {
        my $new_var = &replace_env_var($entry, $md);
        if ($new_var ne "") {
          $body = $body.$new_var;
          $current_pos = $entry->{'STOP'} + 1;
        } else {
          $current_pos = $e;
        }
      }
    } elsif (exists $func_ptr->{'VEC_ASSIGN'}->{$e}) {
      my $vec_entry = $func_ptr->{'VEC_ASSIGN'}->{$e}->{'VEC_INFO'};
      if ($vec_entry->{'FROM_PARAM'}) {
        if ($vec_entry->{'TYPE'} eq "VecQ") {
          $body = $body."$func_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'}";
          $current_pos = $vec_entry->{'STOP'} + 1;
        } else {
          $body = $body."{\n";
          $body = $body."$VecCodeToCType{$vec_entry->{'TYPE'}} vec_assign_tmp = ($VecCodeToCType{$vec_entry->{'TYPE'}})$func_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'};\n";
          $body = $body."vec_assign_tmp[".$vec_entry->{'DEF_SYM_INFO'}->[$#{$vec_entry->{'DEF_SYM_INFO'}}]->{'ARRAY_IDX'}."] ";
          my $sub_head = $func_ptr->{'VEC_ASSIGN'}->{$e}->{'ASSIGN_POS'};
          my $sub_current = $sub_head;
          while ($sub_current != $func_ptr->{'VEC_ASSIGN'}->{$e}->{'SEMI_POS'}) {
            if (exists $func_ptr->{'VEC'}->{$sub_current}) {
              my $sub_str = &GetText($sub_head, ($sub_current-1));
              $body = $body.$sub_str;

              if ($func_ptr->{'VEC'}->{$sub_current}->{'FROM_PARAM'}) {
                $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$sub_current}->{'TYPE'}})$func_ptr->{'VECTOR_ARGS'}->[$func_ptr->{'VEC'}->{$sub_current}->{'VAR'}]->{'VAR_NAME'})";
              } else {
                $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$sub_current}->{'TYPE'}})$func_ptr->{'VEC'}->{$sub_current}->{'VAR'})";
              }
              $sub_head = $func_ptr->{'VEC'}->{$sub_current}->{'STOP'} + 1;
              $sub_current = $sub_head;
            } else {
              $sub_current = $sub_current + 1;
            }
          }
          my $sub_str = &GetText($sub_head, $sub_current);
          $body = $body.$sub_str;
          $body = $body."\n$func_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'} = (v2ulong)vec_assign_tmp;\n";
          $body = $body."}\n";
          $current_pos = $sub_current + 1;
        }
      } else {
        # FIXME
        $body = $body."(($VecCodeToCType{$vec_entry->{'TYPE'}})$vec_entry->{'VAR'})";
        $current_pos = $vec_entry->{'STOP'} + 1;
      }
    } else {
      die "";
    }
  }
  my $txt = &GetText($current_pos, $func_ptr->{'BODY_STOP'});
  $body = $body.$txt;
  return $body;
}

sub update_func_call
{
  my ($caller_ptr, $call_pos, $callee_ptr, $path_info) = @_;
  my $call_info = $caller_ptr->{'CALLS'}->{$call_pos};
  my $str = "";
  if ($callee_ptr->{'DO_EXPAND'}) {
    $str = $callee_ptr->{'NAME'}."_".$path_info."_".$caller_ptr->{'NAME'}."_loc".$call_pos;
  } else {
    $str = $callee_ptr->{'NAME'};
  }
  $str = $str."(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $a = $qemuaot_gp_params[$idx];
    if ($idx == 0) {
      $str = $str.$a;
    } else {
      $str = $str.", ".$a;
    }
  }
  $str = $str.", $qemuaot_vec_invoke";
  my %sub_calls = ();
  foreach my $e (keys %{$caller_ptr->{'CALLS'}}) {
    if ($e > $call_info->{'PAREN_START'} and $e < $call_info->{'PAREN_STOP'}) {
      $sub_calls{$e} = 1;
    }
  }
  my @sorted_sub_calls = sort {$a <=> $b} keys %sub_calls;
  my $sub_call_idx = 0;
  foreach my $idx (0 .. $#{$call_info->{'SCALAR_CALL_ARGS'}}) {
    my $arg = $call_info->{'SCALAR_CALL_ARGS'}->[$idx];
    if ($arg =~ /\(/ and (not $arg =~ /^\(/)) {
      die "" if not $arg =~ /\)/;
      die "$caller_ptr->{'NAME'} $callee_ptr->{'NAME'}" if not exists $sorted_sub_calls[$sub_call_idx];
      my $sub_call_info = $caller_ptr->{'CALLS'}->{$sorted_sub_calls[$sub_call_idx]};
      if (exists $funcs{$sub_call_info->{'CALL_TARGET'}}) {
        my $sub_call_txt = &update_func_call($caller_ptr, $sorted_sub_calls[$sub_call_idx], $funcs{$sub_call_info->{'CALL_TARGET'}}, $path_info);
        $str = $str.", ".$sub_call_txt;
      } else {
        $str = $str.", ".$arg;
      }
      $sub_call_idx = $sub_call_idx + 1;
    } else {
      my $range_info = $call_info->{'SCALAR_CALL_ARG_RANGES'}->[$idx];
      my @vecs = ();
      foreach my $e (keys %{$caller_ptr->{'VEC'}}) {
        if ($e >= $range_info->{'START'} and $e < $range_info->{'STOP'}) {
          push @vecs, $e;
        }
      }
      if (@vecs != 0) {
        $str = $str.", ";
        @vecs = sort {$a <=> $b} @vecs;
        my $last_dump = $range_info->{'START'};
        foreach my $pos (@vecs) {
          if ($last_dump < $pos) {
            my $sub_str = &GetText($last_dump, $pos - 1);
            $str = $str.$sub_str;
          }
          my $vec_entry = $caller_ptr->{'VEC'}->{$pos};

          if ($vec_entry->{'FROM_PARAM'}) {
            $str = $str."(($VecCodeToCType{$vec_entry->{'TYPE'}})$caller_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'})";
          } else {
            $str = $str."(($VecCodeToCType{$vec_entry->{'TYPE'}})$vec_entry->{'VAR'})";
          }
          $last_dump = $vec_entry->{'STOP'} + 1;
        }
        if ($last_dump <= $range_info->{'STOP'}) {
          my $sub_str = &GetText($last_dump, $range_info->{'STOP'});
          $str = $str.$sub_str;
        }
      } else {
        $str = $str.", ".$arg;
      }
    }
  }
  if (exists $callee_ptr->{'IS_FOREIGN'}) {
    $str = $str.", normal_return, exception_return";
  }
  $str = $str.")";
  return $str;
}

sub collect_func_args
{
  my ($func_ptr) = @_;
  my $args = "";
  foreach my $g (@qemuaot_gp_params) {
    $args = $args.$qemuaot_gp_params_map{$g}." ".$g.", ";
  }
  $args = $args.$qemuaot_vec_declare;
  foreach my $i (@{$func_ptr->{'SCALAR_ARGS'}}) {
    $args = $args.", ".$i->{'TYPE'}." ".$i->{'VAR_NAME'};
  }
  if (exists $func_ptr->{'IS_FOREIGN'}) {
    $args = $args.", unsigned long normal_return, unsigned long exception_return";
  }
  return $args;
}

# There could be function call within arguments
sub ExtractCallArguments
{
  my ($input, $start_idx) = @_;
  my @output = ();
  my @comma_split_fields = split(/,/, $input);
  my @size_cnt = ();
  foreach my $csf (@comma_split_fields) {
    my @sub_fields = split(//, $csf);
    my $cnt = @sub_fields;
    push @size_cnt, $cnt;
  }
  my @range = ();
  foreach my $s (@size_cnt) {
    my %info = ();
    $info{'START'} = $start_idx;
    $info{'STOP'} = $start_idx + $s - 1;
    push @range, \%info;
    $start_idx = $info{'STOP'} + 2;
  }
  $input =~ s/\n/ /g;
  $input =~ s/^\s*//;
  $input =~ s/\s*$//;
  my @chars = split(//, $input);
  my $idx = 0;
  while ($idx <= $#chars) {
    my $start_idx = $idx;
    while (&IsValidSymbolStart($chars[$idx]) == 0) {
      $idx = $idx + 1;
      if ($idx > $#chars) {
        last;
      }
    }
    if ($idx > $#chars) {
      my @elems = @chars[$start_idx..$#chars];
      my $elem = join("", @elems);
      push @output, $elem;
      last;
    }
    my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@chars, $idx, 0);
    $idx = $sym_stop + 1;
    if ($idx > $#chars) {
      my @elems = @chars[$start_idx..$#chars];
      my $elem = join("", @elems);
      push @output, $elem;
      last;
    }
    while (1) {
      while ($chars[$idx] ne "(" and $chars[$idx] ne ",") {
        $idx = $idx + 1;
        if ($idx > $#chars) {
          last;
        }
      }
      if ($idx > $#chars) {
        my @elems = @chars[$start_idx..$#chars];
        my $elem = join("", @elems);
        push @output, $elem;
        last;
      }
      if ($chars[$idx] eq "(") {
        my $cnt = 1;
        while ($cnt != 0) {
          $idx = $idx + 1;
          die "" if ($idx > $#chars);
          if ($chars[$idx] eq "(") {
            $cnt = $cnt + 1;
          } elsif ($chars[$idx] eq ")") {
            $cnt = $cnt - 1;
          }
        }
      } elsif ($chars[$idx] eq ",") {
        my @elems = @chars[$start_idx..($idx-1)];
        my $elem = join("", @elems);
        push @output, $elem;
        last;
      } else {
        die "";
      }
    }
    if ($idx > $#chars) {
      last;
    }
    if ($chars[$idx] eq ",") {
      $idx = $idx + 1;
    }
    while ($idx <= $#chars and $chars[$idx] =~ /\s/) {
      $idx = $idx + 1;
    }
    if ($idx > $#chars) {
      last;
    }
  }
  return (\@output, \@range);
}

sub IsValidSymbolStart
{
  my ($c) = @_;
  if (("a" le $c and $c le "z") or
      ("A" le $c and $c le "Z") or
      ("0" le $c and $c le "9") or
      $c eq "_") {
    return 1;
  } else {
    return 0;
  }
}

sub FuncNameIsForeign
{
  my ($func_name) = @_;
  if (exists $funcs{$func_name}) {
    return 0;
  } elsif ($func_name =~ /^__builtin_/) {
    return 0;
  } else {
    return 1;
  }
}

sub replace_env_var
{
  my ($entry, $md) = @_;
  if ($#{$entry->{'DEF_SYM_INFO'}} == -1) {
    return "env";
  }
  my $new_var = "";
  if ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_src") {
    $new_var = "src1";
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_dst") {
    $new_var = "dst";
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_op") {
    $new_var = "op";
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "regs") {
    die "" if $entry->{'DEF_SYM_INFO'}->[0]->{'IS_ARRAY'} == 0;
    my $reg_idx = $entry->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'};
    if (exists $md->{$reg_idx}) {
      $reg_idx = $md->{$reg_idx};
    }
    die "" if not exists $env_reg_idx_map{$reg_idx};
    $new_var = $env_reg_idx_map{$reg_idx};
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "xmm_regs") {
    die "" if $entry->{'DEF_SYM_INFO'}->[0]->{'IS_ARRAY'} == 0;
    my $xmm_idx = $entry->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'};
    die "" if not exists $env_xmmregs_idx_map{$xmm_idx};
    die "" if $entry->{'DEF_SYM_INFO'}->[1]->{'IS_ARRAY'} == 0;
    my $vec_sym = $entry->{'DEF_SYM_INFO'}->[1]->{'SYM'};
    die "" if not exists $VecSymbolToCType{$vec_sym};
    my $vec_idx = $entry->{'DEF_SYM_INFO'}->[1]->{'ARRAY_IDX'};
    $new_var = "(($VecSymbolToCType{$vec_sym})$env_xmmregs_idx_map{$xmm_idx})[$vec_idx]";
  }
  return $new_var;
}

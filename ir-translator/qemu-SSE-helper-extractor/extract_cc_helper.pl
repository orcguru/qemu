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
# Value: does helper have return value or not
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
    my %entries = ();
    $info{'ENTRIES'} = \%entries;
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
    $info{'TYPE'} = "CALL";
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
    $funcs{$addr_to_func{$sorted_addr[$func_idx]}}->{'ENTRIES'}->{$info{'RETURN_START'}} = \%info;
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
    $funcs{$addr_to_func{$sorted_addr[$func_idx]}}->{'ENTRIES'}->{$info{'RETURN_START'}} = \%info;
  }
}
close FD;

# Do insert call into ENTRIES if not hit return
foreach my $f (keys %funcs) {
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $hit = &call_hit_return($e, $funcs{$f});
    if ($hit == 0) {
      $funcs{$f}->{'ENTRIES'}->{$funcs{$f}->{'CALLS'}->{$e}->{'NAME_START'}} = $funcs{$f}->{'CALLS'}->{$e};
    }
  }
}

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

# Collect information, and recursively mark function as final return
my %sub_funcs = ();
my %defined_funcs_total = ();
foreach my $f (keys %helpers) {
  my @sf = ();
  $sub_funcs{$f} = \@sf;
  my @sub_call_stack = ();
  if (not exists $funcs{$f}) {
    die "$f not defined1!\n";
  }
  $funcs{$f}->{'TAIL_RETURN'} = 1;
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $call_target = $funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'};
    my $hit = &call_hit_return($e, $funcs{$f});
    if ($hit and $funcs{$f}->{'TAIL_RETURN'} and exists $funcs{$call_target}) {
      $funcs{$call_target}->{'TAIL_RETURN'} = 1;
    }
    unshift @sf, $call_target;
    if (exists $funcs{$call_target}) {
      $defined_funcs_total{$call_target} = 1;
    }
    push @sub_call_stack, $call_target;
  }
  while (@sub_call_stack > 0) {
    my @new_call_stack = ();
    foreach my $c (@sub_call_stack) {
      if (not exists $funcs{$c}) {
        #print "$c not defined!\n";
        next;
      }
      foreach my $e (keys %{$funcs{$c}->{'CALLS'}}) {
        my $call_target = $funcs{$c}->{'CALLS'}->{$e}->{'CALL_TARGET'};
        my $hit = &call_hit_return($e, $funcs{$c});
        if ($hit and $funcs{$c}->{'TAIL_RETURN'} and exists $funcs{$call_target}) {
          $funcs{$call_target}->{'TAIL_RETURN'} = 1;
        }
        unshift @sf, $call_target;
        if (exists $funcs{$call_target}) {
          $defined_funcs_total{$call_target} = 1;
        }
        push @new_call_stack, $call_target;
      }
    }
    @sub_call_stack = @new_call_stack;
  }
}

# Check that function as tail return is always tail return, and vise versa
foreach my $f (keys %defined_funcs_total) {
  my $expect_tail_return = 0;
  if (exists $funcs{$f}->{'TAIL_RETURN'}) {
    #print "FUNC $f is tail return\n";
    $expect_tail_return = 1;
  } else {
    #print "FUNC $f is non-tail return\n";
  }
  foreach my $cf (keys %defined_funcs_total) {
    foreach my $e (keys %{$funcs{$cf}->{'CALLS'}}) {
      my $call_target = $funcs{$cf}->{'CALLS'}->{$e}->{'CALL_TARGET'};
      if ($call_target eq $f) {
        my $hit = &call_hit_return($e, $funcs{$cf});
        if (not exists $funcs{$cf}->{'TAIL_RETURN'}) {
          $hit = 0;
        }
        if ($hit != $expect_tail_return) {
          die "Check $f non-uniform tail return\n";
        }
      }
    }
  }
}

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
my $qemuaot_vec_invoke = "xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h, xmm15, ymm15_h";
my $qemuaot_vec_declare = "v2ulong xmm0, v2ulong ymm0_h, v2ulong xmm1, v2ulong ymm1_h, v2ulong xmm2, v2ulong ymm2_h, v2ulong xmm3, v2ulong ymm3_h, v2ulong xmm4, v2ulong ymm4_h, v2ulong xmm5, v2ulong ymm5_h, v2ulong xmm6, v2ulong ymm6_h, v2ulong xmm7, v2ulong ymm7_h, v2ulong xmm8, v2ulong ymm8_h, v2ulong xmm9, v2ulong ymm9_h, v2ulong xmm10, v2ulong ymm10_h, v2ulong xmm11, v2ulong ymm11_h, v2ulong xmm12, v2ulong ymm12_h, v2ulong xmm13, v2ulong ymm13_h, v2ulong xmm14, v2ulong ymm14_h, v2ulong xmm15, v2ulong ymm15_h";

# Generate functions
foreach my $f (keys %helpers) {
  # Cleanup PARAM_MAP/PARAM_ARRAY among all functions to avoid interference
  foreach my $c (keys %funcs) {
    if (exists $funcs{$c}->{'PARAM_MAP'}) {
      delete $funcs{$c}->{'PARAM_MAP'};
    }
    if (exists $funcs{$c}->{'PARAM_ARRAY'}) {
      delete $funcs{$c}->{'PARAM_ARRAY'};
    }
  }

  # Setup QEMUAOT CC parameter map in functions
  my ($func_name, $arguments) = &get_func_name_parts($funcs{$f}, 1);
  my %param_map = ();
  my @param_array = ();
  foreach my $idx (0 .. $#{$arguments}) {
    my $a = $arguments->[$idx]->{'VAR_NAME'};
    my %info = ();
    $info{'IDX'} = $idx;
    $info{'TYPE'} = $arguments->[$idx]->{'TYPE'};
    $info{'ORIG'} = $a;
    $info{'QEMUAOT'} = "NA";
    if (exists $qemuaot_gp_params_map{$a}) {
      $info{'QEMUAOT'} = $a;
    }
    $param_map{$a} = \%info;
    push @param_array, \%info;
  }
  $funcs{$f}->{'PARAM_MAP'} = \%param_map;
  $funcs{$f}->{'PARAM_ARRAY'} = \@param_array;

  my @sub_call_stack = ();
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $call_target = $funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'};
    if (exists $funcs{$call_target}) {
      &check_sub_func_for_param_map($f, $call_target, $e);
      push @sub_call_stack, $call_target;
    }
  }
  while (@sub_call_stack > 0) {
    my @new_call_stack = ();
    foreach my $c (@sub_call_stack) {
      if (not exists $funcs{$c}) {
        next;
      }
      foreach my $e (keys %{$funcs{$c}->{'CALLS'}}) {
        my $call_target = $funcs{$c}->{'CALLS'}->{$e}->{'CALL_TARGET'};
        if (exists $funcs{$call_target}) {
          &check_sub_func_for_param_map($c, $call_target, $e);
          push @new_call_stack, $call_target;
        }
      }
    }
    @sub_call_stack = @new_call_stack;
  }

  open OUT, "> $path/$f.c" or die "Cannot open $path/$f.c for write!\n";
  print OUT "$blank_info\n\n";
  print OUT "typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;\n";
  print OUT "extern __attribute__((qemuaot)) void FUNC_NORMAL_RET(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    print OUT "$qemuaot_gp_params_map{$p} $p, ";
  }
  if ($helpers{$f}) {
    print OUT "$qemuaot_vec_declare, unsigned long ret_val);\n";
  } else {
    print OUT "$qemuaot_vec_declare);\n";
  }
  print OUT "extern __attribute__((qemuaot)) void FUNC_EXCEPTION_RET(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    print OUT "$qemuaot_gp_params_map{$p} $p, ";
  }
  print OUT "$qemuaot_vec_declare, unsigned long helper, unsigned long func_secondary);\n";
  print OUT "extern __attribute__((qemuaot)) void FUNC_SECONDARY(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    print OUT "$qemuaot_gp_params_map{$p} $p, ";
  }
  if ($helpers{$f}) {
    print OUT "$qemuaot_vec_declare, unsigned long ret_val);\n";
  } else {
    print OUT "$qemuaot_vec_declare);\n";
  }
  my $extern_func = &GetText($funcs{$f}->{'FULL_START'}, $funcs{$f}->{'NAME_STOP'}, $ARGV[0]);
  print OUT "extern $extern_func;\n\n";
  my %covered_sub_funcs = ();
  foreach my $s (@{$sub_funcs{$f}}) {
    if (not exists $covered_sub_funcs{$s}) {
      $covered_sub_funcs{$s} = 1;
      if (exists $funcs{$s}) {
        my $new_func = &gen_new_func($funcs{$s}, 0, $f);
        print OUT "$new_func\n\n";
      }
    }
  }
  my $new_func = &gen_new_func($funcs{$f}, 1, $f);
  print OUT "$new_func\n\n";
  close OUT;
}

sub check_sub_func_for_param_map
{
  my ($parent, $child, $call) = @_;
  my $param_list = &get_call_param_list($funcs{$parent}->{'CALLS'}->{$call}->{'PAREN_START'}, $funcs{$parent}->{'CALLS'}->{$call}->{'PAREN_STOP'});
  foreach my $idx (0 .. $#{$param_list}) {
    if (not exists $funcs{$parent}->{'PARAM_MAP'}->{$param_list->[$idx]}) {
      $param_list->[$idx] = "NA";
    } else {
      $param_list->[$idx] = $funcs{$parent}->{'PARAM_MAP'}->{$param_list->[$idx]}->{'QEMUAOT'};
    }
  }
  if (exists $funcs{$child}->{'PARAM_MAP'}) {
    foreach my $idx (0 .. $#{$param_list}) {
      if ($funcs{$child}->{'PARAM_ARRAY'}->[$idx]->{'QEMUAOT'} ne $param_list->[$idx]) {
        $funcs{$child}->{'PARAM_ARRAY'}->[$idx]->{'QEMUAOT'} = "NA";
      }
    }
  } else {
    my ($func_name, $arguments) = &get_func_name_parts($funcs{$child}, 0);
    my %param_map = ();
    my @param_array = ();
    foreach my $idx (0 .. $#{$arguments}) {
      my $a = $arguments->[$idx]->{'VAR_NAME'};
      my %info = ();
      $info{'IDX'} = $idx;
      $info{'TYPE'} = $arguments->[$idx]->{'TYPE'};
      $info{'ORIG'} = $a;
      $info{'QEMUAOT'} = $param_list->[$idx];
      $param_map{$a} = \%info;
      push @param_array, \%info;
    }
    $funcs{$child}->{'PARAM_MAP'} = \%param_map;
    $funcs{$child}->{'PARAM_ARRAY'} = \@param_array;
  }
}

# Handle function update for QEMUAOT calling convention
sub gen_new_func
{
  my ($func, $external, $exception_exit) = @_;
  my $new_func = "";
  my %update_param_name = ();
  foreach my $k (keys %{$func->{'PARAM_MAP'}}) {
    if ($func->{'PARAM_MAP'}->{$k}->{'QEMUAOT'} ne "NA") {
      $update_param_name{$func->{'PARAM_MAP'}->{$k}->{'QEMUAOT'}} = $func->{'PARAM_MAP'}->{$k}->{'ORIG'};
    }
  }
  my ($func_name, $arguments) = &get_func_name_parts($func, $external);
  if ($external) {
    $new_func = "__attribute__((qemuaot,flatten)) ".$func_name."(";
  } else {
    $new_func = "__attribute__((qemuaot)) ".$func_name."(";
  }
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    $new_func = $new_func.$qemuaot_gp_params_map{$p};
    if (exists $update_param_name{$p}) {
      $new_func = $new_func." ".$update_param_name{$p};
    } else {
      $new_func = $new_func." ".$p;
    }
    $new_func = $new_func.", ";
  }
  $new_func = $new_func.$qemuaot_vec_declare;
  foreach my $k (@{$func->{'PARAM_ARRAY'}}) {
    if ($k->{'QEMUAOT'} eq "NA") {
      $new_func = $new_func.", $k->{'TYPE'} $k->{'ORIG'}";
    }
  }
  $new_func = $new_func.")";

  # Sort list of calls/returns that need be patched
  my @sorted_entries = sort {$a <=> $b} keys %{$func->{'ENTRIES'}};
  my $current_pos = $func->{'NAME_STOP'} + 1;
  foreach my $e (@sorted_entries) {
    my $txt = &GetText($current_pos, ($e - 1), $ARGV[0]);
    $new_func = $new_func.$txt;
    if ($func->{'ENTRIES'}->{$e}->{'TYPE'} eq "CALL") {
      my $call_target = $func->{'ENTRIES'}->{$e}->{'CALL_TARGET'};
      if ((not exists $funcs{$call_target}) and (not $call_target =~ /builtin/)) {
        # Not able to handle, redirect to runtime
        $new_func = $new_func."FUNC_EXCEPTION_RET(";
        foreach my $idx (0 .. $#qemuaot_gp_params) {
          my $p = $qemuaot_gp_params[$idx];
          if (exists $update_param_name{$p}) {
            $new_func = $new_func.$update_param_name{$p};
          } else {
            $new_func = $new_func.$p;
          }
          $new_func = $new_func.", ";
        }
        $new_func = $new_func.$qemuaot_vec_invoke.", (unsigned long)$exception_exit, (unsigned long)FUNC_SECONDARY)";
      } else {
        $new_func = $new_func.$call_target."(";
        foreach my $idx (0 .. $#qemuaot_gp_params) {
          my $p = $qemuaot_gp_params[$idx];
          if (exists $update_param_name{$p}) {
            $new_func = $new_func.$update_param_name{$p};
          } else {
            $new_func = $new_func.$p;
          }
          $new_func = $new_func.", ";
        }
        $new_func = $new_func.$qemuaot_vec_invoke;
        my $param_list = &get_call_param_list($func->{'ENTRIES'}->{$e}->{'PAREN_START'}, $func->{'ENTRIES'}->{$e}->{'PAREN_STOP'});
        foreach my $idx (0 .. $#{$funcs{$call_target}->{'PARAM_ARRAY'}}) {
          if ($funcs{$call_target}->{'PARAM_ARRAY'}->[$idx]->{'QEMUAOT'} eq "NA") {
            $new_func = $new_func.", ".$param_list->[$idx];
          }
        }
        $new_func = $new_func.")";
      }
      $current_pos = $func->{'ENTRIES'}->{$e}->{'PAREN_STOP'} + 1;
    } elsif ($func->{'ENTRIES'}->{$e}->{'TYPE'} eq "RETURN_VOID") {
      die "Not expected return void!\n";
    } elsif ($func->{'ENTRIES'}->{$e}->{'TYPE'} eq "RETURN_EXPR") {
      my $is_call = 0;
      my $call;
      my $param_list;
      foreach my $ck (keys %{$func->{'CALLS'}}) {
        if ($ck > $func->{'ENTRIES'}->{$e}->{'RETURN_START'} and $ck < $func->{'ENTRIES'}->{$e}->{'RETURN_STOP'}) {
          $is_call = 1;
          $call = $func->{'CALLS'}->{$ck};
          $param_list = &get_call_param_list($call->{'PAREN_START'}, $call->{'PAREN_STOP'});
          if ((not exists $funcs{$call->{'CALL_TARGET'}}) and (not $call->{'CALL_TARGET'} =~ /builtin/)) {
            die "$call->{'CALL_TARGET'} not defined2!\n";
          }
          last;
        }
      }
      if ($is_call and $call->{'CALL_TARGET'} =~ /builtin/) {
        if (exists $func->{'TAIL_RETURN'}) {
          die "Unexpected!\n";
        }
        my $txt = &GetText($func->{'ENTRIES'}->{$e}->{'RETURN_START'}, $func->{'ENTRIES'}->{$e}->{'RETURN_STOP'}, $ARGV[0]);
        $new_func = $new_func.$txt;
      } else {
        if (exists $func->{'TAIL_RETURN'}) {
          if ($is_call) {
            my $txt = &handle_call_hit_return_expr($call, $func->{'ENTRIES'}->{$e}, \%update_param_name, $param_list);
            $new_func = $new_func.$txt;
          } else {
            $new_func = $new_func."return ";
            $new_func = $new_func."FUNC_NORMAL_RET(";
            foreach my $idx (0 .. $#qemuaot_gp_params) {
              my $p = $qemuaot_gp_params[$idx];
              if (exists $update_param_name{$p}) {
                $new_func = $new_func.$update_param_name{$p};
              } else {
                $new_func = $new_func.$p;
              }
              $new_func = $new_func.", ";
            }
            $new_func = $new_func.$qemuaot_vec_invoke;
            my $txt = &GetText($func->{'ENTRIES'}->{$e}->{'EXPR_START'}, $func->{'ENTRIES'}->{$e}->{'EXPR_STOP'}, $ARGV[0]);
            $new_func = $new_func.", (unsigned long)(".$txt.")";
            $new_func = $new_func.");";
          }
        } else {
          my $txt = "";
          if ($is_call) {
            $txt = &handle_call_hit_return_expr($call, $func->{'ENTRIES'}->{$e}, \%update_param_name, $param_list);
          } else {
            $txt = &GetText($func->{'ENTRIES'}->{$e}->{'RETURN_START'}, $func->{'ENTRIES'}->{$e}->{'RETURN_STOP'}, $ARGV[0]);
          }
          $new_func = $new_func.$txt;
        }
      }
      $current_pos = $func->{'ENTRIES'}->{$e}->{'RETURN_STOP'} + 1;
    } else {
      die "Unsupported entry!\n";
    }
  }
  my $txt = &GetText($current_pos, $func->{'FULL_STOP'}, $ARGV[0]);
  $new_func = $new_func.$txt;
  return $new_func;
}

# FIXME: there could be multiple calls within one return_expr
sub handle_call_hit_return_expr
{
  my ($call, $return, $update, $param_list) = @_;
  my $str = "return ";
  if ($call->{'NAME_START'} != $return->{'EXPR_START'}) {
    if ($call->{'NAME_START'} < $return->{'EXPR_START'}) {
      die "Unexpected call hit return_expr!\n";
    }
    my $sub = &GetText($return->{'EXPR_START'}, ($call->{'NAME_START'} - 1), $ARGV[0]);
    $str = $str.$sub;
  }
  $str = $str.$call->{'CALL_TARGET'}."(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    if (exists $update->{$p}) {
      $str = $str.$update->{$p};
    } else {
      $str = $str.$p;
    }
    $str = $str.", ";
  }
  $str = $str.$qemuaot_vec_invoke;
  foreach my $idx (0 .. $#{$funcs{$call->{'CALL_TARGET'}}->{'PARAM_ARRAY'}}) {
    if ($funcs{$call->{'CALL_TARGET'}}->{'PARAM_ARRAY'}->[$idx]->{'QEMUAOT'} eq "NA") {
      $str = $str.", ".$param_list->[$idx];
    }
  }
  $str = $str.")";
  if ($call->{'PAREN_STOP'} != $return->{'EXPR_STOP'}) {
    if ($call->{'PAREN_STOP'} > $return->{'EXPR_STOP'}) {
      die "Unexpected call hit return_expr!\n";
    }
    my $sub = &GetText(($call->{'PAREN_STOP'} + 1), $return->{'EXPR_STOP'}, $ARGV[0]);
    $str = $str.$sub;
  }
  my $sub = &GetText(($return->{'EXPR_STOP'} + 1), $return->{'RETURN_STOP'}, $ARGV[0]);
  $str = $str.$sub;
  return $str;
}

sub get_call_param_list
{
  my ($paren_start, $paren_stop) = @_;
  my $str = &GetText($paren_start, $paren_stop, $ARGV[0]);
  $str =~ s/^\s*\(\s*//;
  $str =~ s/\s*\)\s*$//;
  my @fields = split(/,/, $str);
  foreach my $i (0 .. $#fields) {
    $fields[$i] =~ s/^\s*//;
    $fields[$i] =~ s/\s*$//;
  }
  return \@fields;
}

sub get_func_name_parts
{
  my ($func, $external) = @_;
  my $str = "";
  if (exists $func->{'TAIL_RETURN'}) {
    $str = &GetText($func->{'NAME_START'}, $func->{'NAME_STOP'}, $ARGV[0]);
    if ($external) {
      $str =~ s/^$func->{'FUNC_NAME'}/HELPER_NAME/;
      $str = "void ".$str;
    } else {
      $str = "static inline void ".$str;
    }
  } else {
    $str = &GetText($func->{'FULL_START'}, $func->{'NAME_STOP'}, $ARGV[0]);
  }
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
  my $tail = join("", @slice_tail);
  $tail =~ s/^\(\s*//;
  $tail =~ s/\s*\)\s*$//;
  my @fields = split(/,/, $tail);
  my @params = ();
  foreach my $i (0 .. $#fields) {
    $fields[$i] =~ s/^\s*//;
    $fields[$i] =~ s/\s*$//;
    my @sub_fields = split(/\s+/, $fields[$i]);
    if (@sub_fields != 2) {
      die "Complex type not supported yet!\n";
    }
    my %info = ();
    $info{'TYPE'} = $sub_fields[0];
    $info{'VAR_NAME'} = $sub_fields[1];
    push @params, \%info;
  }
  return ($head, \@params);
}

sub call_hit_return
{
  my ($call_loc, $func) = @_;
  foreach my $r (keys %{$func->{'RETURNS'}}) {
    if ($func->{'RETURNS'}->{$r}->{'RETURN_START'} < $call_loc and $func->{'RETURNS'}->{$r}->{'RETURN_STOP'} > $call_loc) {
      return 1;
    }
  }
  return 0;
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
  $ret = unpack "a*", $bytes;
  close FDIN;
  return $ret;
}

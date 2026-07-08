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

my %fp_helpers = (
  "helper_comisd" => 1,
  "helper_ucomisd" => 1,
);

my $arch_info = `uname -m`;
chomp($arch_info);
my %VecCodeToCType = (
  "VecQ" => "v2ulong",
  "VecL" => "v4uint",
  "VecW" => "v8ushort",
  "VecB" => "v16uchar",
);
my %VecSymbolToCType = (
  "_q_ZMMReg" => "v2ulong",
  "_l_ZMMReg" => "v4uint",
  "_w_ZMMReg" => "v8ushort",
  "_b_ZMMReg" => "v16uchar",
);
my @qemuaot_gp_params = ("rax", "rcx", "rdx", "rbx", "rsp", "rbp", "rsi", "rdi", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "qemuaot_src1", "qemuaot_dst", "qemuaot_op", "rip");
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
  "qemuaot_src1" => "unsigned long",
  "qemuaot_dst" => "unsigned long",
  "qemuaot_op" => "unsigned int",
  "rip" => "unsigned long",
  "env->sse_status" => "float_status"
);
my $qemuaot_vec_invoke = "XMM_PARAM_LIST";
my $qemuaot_vec_declare = "XMM_PARAM_DECLARE_COMMON";
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

my $path = "$ARGV[0].helper_floatingpoint";
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
    $info{'HELPER_INTERFACE'} = 0;
    if (exists $fp_helpers{$info{'NAME'}}) {
      $info{'HELPER_INTERFACE'} = 1;
    }
    $info{'FUNC_FULL'} = &GetText($bodyStart, $bodyStop);
    $info{'FUNC_IDX'} = $global_func_idx;
    $global_func_idx = $global_func_idx + 1;
    my %calls = ();
    $info{'CALLS'} = \%calls;
    my %vec_assign = ();
    $info{'VEC_ASSIGN'} = \%vec_assign;
    my %returns = ();
    $info{'RETURNS'} = \%returns;
    my %backup_info = ();
    $info{'ENVVAR_AND_VECTORS'} = \%backup_info;
    if (exists $funcs{$info{'NAME'}}) {
      #print "Duplicated function definition $info{'NAME'}!\n";
      $info{'NAME'} = $info{'NAME'}."__DUPLICATED";
    }
    $info{'DO_EXPAND'} = 0;
    $funcs{$info{'NAME'}} = \%info;
    $func_lookup{'MAP'}->{$info{'LOOKUP_START'}} = \%info;
  }
}
close FD;
my @sorted_func_addr = sort {$a <=> $b} sort keys %{$func_lookup{'MAP'}};
$func_lookup{'SORTED_ADDR'} = \@sorted_func_addr;

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

# Collect call sites 
my %callsite_lookup = ();
my %callsite_lookup_map = ();
$callsite_lookup{'MAP'} = \%callsite_lookup_map;
my $prev_generic_func = "";
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
    my $check_call = &GetText(($info{'NAME_STOP'} + 1), $info{'PAREN_START'});
    if (not $check_call =~ /^\s*\(/) {
      next;
    }
    $info{'CALL_TARGET'} = &GetText($info{'NAME_START'}, $info{'NAME_STOP'});
    if ($info{'CALL_TARGET'} eq '_Generic') {
        my $generic_call = &GetText($info{'PAREN_START'}, $info{'PAREN_STOP'});
        if ($generic_call =~ /:/) {
          $generic_call =~ s/^\(//;
          $generic_call =~ s/\)$//;
          my @fields = split(/,/, $generic_call);
          my $generic_var = $fields[0];
          $generic_var =~ s/^\s+//;
          $generic_var =~ s/\s+$//;
          $generic_var =~ s/^\(//;
          $generic_var =~ s/\)$//;
          my $got_addr = 0;
          if ($generic_var =~ /^\&/) {
            $generic_var =~ s/^\&//;
            $got_addr = 1;
          }
          my $generic_var_type = "";
          my ($func_idx, $ptr) = &lookup($info{'NAME_START'}, \%func_lookup);
          if ($func_idx != -1) {
            $info{'PARENT'} = $ptr->{'NAME'};
            if (not exists $ptr->{'GENERIC_EARLY_INIT'}) {
              my ($head, $scalar_args, $vector_args, $pure_arg_info, $ret128_info, $env_type, $func_type) = &parse_func_head($ptr);
              $ptr->{'HEAD'} = $head;
              $ptr->{'PURE_ARG_INFO'} = $pure_arg_info;
              $ptr->{'SCALAR_ARGS'} = $scalar_args;
              $ptr->{'VECTOR_ARGS'} = $vector_args;
              $ptr->{'ENV_TYPE'} = $env_type;
              $ptr->{'128'} = $ret128_info;
              $ptr->{'FUNC_TYPE'} = $func_type;
              $ptr->{'GENERIC_EARLY_INIT'} = 1;
            }
            foreach my $arg (@{$ptr->{'SCALAR_ARGS'}}) {
              if ($arg->{'VAR_NAME'} eq $generic_var) {
                $generic_var_type = $arg->{'TYPE'};
              }
            }
            if ($generic_var_type eq "") {
              my @func_lines = split(/\n/, $ptr->{'FUNC_FULL'});
              foreach my $fl (@func_lines) {
                if ($fl =~ /([a-zA-Z_0-9]+)(\s|\*)+$generic_var/) {
                  $generic_var_type = $1;
                  if ($fl =~ /\*\s*$generic_var/) {
                    $generic_var_type = $generic_var_type." *";
                  }
                  last;
                }
              }
              if ($generic_var_type eq "") {
                foreach my $fl (@func_lines) {
                  if ($fl =~ /(\s|\*)+$generic_var/) {
                    $fl =~ s/^\s+//;
                    my @sub_fields = split(/\s+/, $fl);
                    $generic_var_type = $sub_fields[0];
                    if ($fl =~ /\*\s*$generic_var/) {
                      $generic_var_type = $generic_var_type." *";
                    }
                    last;
                  }
                }
              }
            }
            if ($got_addr and $generic_var_type ne "") {
              $generic_var_type = $generic_var_type." *";
            }
            foreach my $f (@fields) {
              if ($f =~ /:/) {
                my @sub_fields = split(/:/, $f);
                $sub_fields[0] =~ s/^\s+//;
                $sub_fields[0] =~ s/\s+$//;
                if ($generic_var_type eq $sub_fields[0]) {
                  $prev_generic_func = $sub_fields[1];
                  $prev_generic_func =~ s/^\s+//;
                  $prev_generic_func =~ s/\s+$//;
                }
              }
            }
            die "" if $prev_generic_func eq "";
          } else {
            $prev_generic_func = "";
            next;
          }
          foreach my $f (@fields) {
            if ($f =~ /:/) {
              my @sub_fields = split(/:/, $f);
              my $generic_func = $sub_fields[1];
              $generic_func =~ s/^\s+//;
              $generic_func =~ s/\s+$//;
              #print "$generic_func\n";
            }
          }
        } else {
          if ($prev_generic_func eq "") {
            next;
          }
          $info{'CALL_TARGET'} = $prev_generic_func;
        }
    }
    my $str = &GetText($info{'PAREN_START'} + 1, $info{'PAREN_STOP'} - 1);
    my ($args, $ranges) = &ExtractCallArguments($str, $info{'PAREN_START'} + 1, $info{'PAREN_STOP'} - 1);
    $info{'CALL_ARGUMENTS'} = $args;
    $info{'CALL_ARGUMENT_RANGES'} = $ranges;
    my ($func_idx, $ptr) = &lookup($info{'NAME_START'}, \%func_lookup);
    if ($func_idx != -1) {
      $info{'PARENT'} = $ptr->{'NAME'};

      # FIX: Check if callee is a function pointer parameter of the parent
      if (&FuncNameIsForeign($info{'CALL_TARGET'})) {
        my $is_param = 0;
        foreach my $arg (@{$ptr->{'SCALAR_ARGS'}}) {
          if ($arg->{'VAR_NAME'} eq $info{'CALL_TARGET'}) {
            $is_param = 1;
            last;
          }
        }
        if (!$is_param) {
          $info{'IS_FOREIGN'} = 1;
          $funcs{$ptr->{'NAME'}}->{'IS_FOREIGN'} = 1;
          foreach my $a (@{$args}) {
            if ($a =~ /^\s*env\s*$/) {
              $ptr->{'DO_DEFINE_ENV'} = 1;
            }
          }
        }
      }

      $funcs{$ptr->{'NAME'}}->{'CALLS'}->{$info{'NAME_START'}} = \%info;
      $callsite_lookup{'MAP'}->{$info{'LOOKUP_START'}} = \%info;
    }
  }
}
close FD;
my @sorted_callsite_addr = sort {$a <=> $b} sort keys %{$callsite_lookup{'MAP'}};
$callsite_lookup{'SORTED_ADDR'} = \@sorted_callsite_addr;

# Collect foreign_funcs types
my %func_type_input = ();
my $line_info = "";
my @blank_lines = split(/\n/, $blank_info);
foreach my $line (@blank_lines) {
  if ($line =~ /^#/) {
    next;
  }
  if (not $line =~ /;/) {
    $line_info = $line_info.$line." ";
  } else {
    $line_info = $line_info.$line;
    if ($line_info =~ /\(/) {
      $line_info =~ s/extern\s+//;
      my @defs = split(/;/, $line_info);
      foreach my $l (@defs) {
        if ($l =~ /\(/) {
          $l =~ s/^\s+//;
          $l =~ s/\s+$//;
          $l = &remove_attribute($l);
          if ($l =~ /\(/) {
            my @fields = split(/\(/, $l);
            my @sub_fields = split(/\s+/, $fields[0]);
            if (@sub_fields > 1) {
              my $valid = 1;
              my @fields_for_type = ();
              foreach my $ls_idx (0..($#sub_fields-1)) {
                my $ls = $sub_fields[$ls_idx];
                if ($ls =~ /__attribute__/ or $ls =~ /extern/) {
                  next;
                }
                if (&IsValidSymbol($ls) == 0) {
                  $valid = 0;
                  last;
                }
                push @fields_for_type, $ls;
              }
              if ($valid == 0) {
                next;
              }
              my $type_info = join(" ", @fields_for_type);
              my $ff_name = $sub_fields[$#sub_fields];
              while ($ff_name =~ /^\*/) {
                $ff_name =~ s/^\*//;
                $type_info = $type_info."*";
              }
              $func_type_input{$ff_name} = $type_info;
            }
          }
        }
      }
    }
    $line_info = "";
  }
}

# Mark functions by fp_helpers
my %covered_funcs = ();
my %workset = ();
foreach my $f (keys %funcs) {
  if (exists $fp_helpers{$f}) {
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
# Remove forward declarations of functions that will be defined later
$blank_info = &filter_blank_info($blank_info, \%covered_funcs);
my %foreign_funcs = ();
foreach my $f (keys %covered_funcs) {
  $funcs{$f}->{'TOUCHED'} = 1;
  my ($head, $scalar_args, $vector_args, $pure_arg_info, $ret128_info, $env_type, $func_type) = &parse_func_head($funcs{$f});
  $funcs{$f}->{'HEAD'} = $head;
  $funcs{$f}->{'PURE_ARG_INFO'} = $pure_arg_info;
  $funcs{$f}->{'SCALAR_ARGS'} = $scalar_args;
  $funcs{$f}->{'VECTOR_ARGS'} = $vector_args;
  $funcs{$f}->{'ENV_TYPE'} = $env_type;
  $funcs{$f}->{'128'} = $ret128_info;
  $funcs{$f}->{'FUNC_TYPE'} = $func_type;
  if (exists $fp_helpers{$funcs{$f}->{'NAME'}} and $funcs{$f}->{'FUNC_TYPE'} ne "void") {
    $funcs{$f}->{'HEAD'} =~ s/$funcs{$f}->{'FUNC_TYPE'}\s+/void /;
  }
  foreach my $e (keys %{$funcs{$f}->{'CALLS'}}) {
    my $ct = $funcs{$f}->{'CALLS'}->{$e}->{'CALL_TARGET'};
    if (&FuncNameIsForeign($ct)) {
      # Skip if the call target is a function pointer parameter of this function
      my $is_param = 0;
      foreach my $arg (@{$funcs{$f}->{'SCALAR_ARGS'}}) {
        if ($arg->{'VAR_NAME'} eq $ct) {
          $is_param = 1;
          last;
        }
      }
      if (!$is_param) {
        $foreign_funcs{$ct} = 1;
      }
    }
  }
}

foreach my $f (keys %foreign_funcs) {
  if (not exists $func_type_input{$f}) {
    print "$f type not detected\n";
  }
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
      if ($func_ptr->{'NAME'} =~ /^helper_/ and $func_ptr->{'NAME'} =~ /_xmm$/) {
        next;
      }
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
      print "$func_ptr->{'NAME'}\n";
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
          # The case for single "env" pointer
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
          # Reference through "env" pointer
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
            die "" if $sym_info[0]->{'IS_ARRAY'} == 1;
            die "" if $func_ptr->{'ENV_TYPE'} eq "NA";
            $func_ptr->{'DO_DEFINE_ENV'} = 1;
            $func_ptr->{'ENVVAR_AND_VECTORS'}->{"env->$sym_info[0]->{'SYM'}"} = 1;
          } else {
            if ($sym_info[0]->{'SYM'} eq "cc_src") {
              $func_ptr->{'ENVVAR_AND_VECTORS'}->{"qemuaot_src1"} = 1;
            }
            if ($sym_info[0]->{'SYM'} eq "cc_dst") {
              $func_ptr->{'ENVVAR_AND_VECTORS'}->{"qemuaot_dst"} = 1;
            }
            if ($sym_info[0]->{'SYM'} eq "cc_op") {
              $func_ptr->{'ENVVAR_AND_VECTORS'}->{"qemuaot_op"} = 1;
            }
            if ($sym_info[0]->{'SYM'} eq "regs") {
              die "" if $sym_info[0]->{'IS_ARRAY'} == 0;
              if (exists $env_reg_idx_map{$sym_info[0]->{'ARRAY_IDX'}}) {
                my $touched_var = $env_reg_idx_map{$sym_info[0]->{'ARRAY_IDX'}};
                $func_ptr->{'ENVVAR_AND_VECTORS'}->{$touched_var} = 1;
              }
            }
            if ($sym_info[0]->{'SYM'} eq "xmm_regs") {
              die "" if $sym_info[0]->{'IS_ARRAY'} == 0;
              if (exists $env_xmmregs_idx_map{$sym_info[0]->{'ARRAY_IDX'}}) {
                my $touched_var = $env_xmmregs_idx_map{$sym_info[0]->{'ARRAY_IDX'}};
                $func_ptr->{'ENVVAR_AND_VECTORS'}->{$touched_var} = 1;
              } else {
                die "";
              }
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
          }
          if ($skip_vec == 0) {
            if (not exists $func_ptr->{'VEC'}) {
              my %info = ();
              $func_ptr->{'VEC'} = \%info;
            }
            $func_ptr->{'VEC'}->{$start} = \%vec_info;
          }
        } else {
          die "" if $env_ptr->{'DEF_SYM_INFO'}->[0]->{'SYM'} ne "xmm_regs";
          my @vec_symbols = ();
          my %info = ();
          $info{'SYM'} = $code;
          $info{'IS_ARRAY'} = 1;
          my ($array_idx, $array_idx_start, $array_idx_stop) = &GetContentWithArrayBound($stop+2);
          $info{'ARRAY_IDX'} = $array_idx;
          if ($file_content[$array_idx_stop+2] eq " " and $file_content[$array_idx_stop+3] eq "=" and $file_content[$array_idx_stop+4] eq " ") {
            unshift @vec_symbols, \%info;
            my %vec_info = ();
            $vec_info{'TXT'} = &GetText($start, $stop);
            $vec_info{'START'} = $env_ptr->{'LOOKUP_START'};
            $vec_info{'STOP'} = $stop;
            $vec_info{'LOOKUP_START'} = $vec_info{'START'};
            $vec_info{'LOOKUP_STOP'} = $vec_info{'STOP'};
            $vec_info{'TYPE'} = $vec_symbols[$#vec_symbols]->{'SYM'};
            die "" if $file_content[$start-1] eq "&";
            $vec_info{'DEF_SYM_INFO'} = \@vec_symbols;

            $vec_info{'FROM_PARAM'} = 0;
            die "$func_ptr->{'NAME'}" if not exists $env_xmmregs_idx_map{$env_ptr->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'}};
            $vec_info{'VAR'} = $env_xmmregs_idx_map{$env_ptr->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'}};

            # Collect vector assignment info
            my %vec_assign = ();
            $vec_assign{'VEC_INFO'} = \%vec_info;
            $vec_assign{'ASSIGN_POS'} = $array_idx_stop+3;
            my $semi_pos = $vec_assign{'ASSIGN_POS'};
            while ($file_content[$semi_pos] ne ";") {
              $semi_pos = $semi_pos + 1;
            }
            $vec_assign{'SEMI_POS'} = $semi_pos;
            $func_ptr->{'VEC_ASSIGN'}->{$vec_info{'START'}} = \%vec_assign;
            delete $func_ptr->{'ENV'}->{$env_ptr->{'LOOKUP_START'}};
          }
        }
      }
    }
  } elsif ($line =~ /^<VecX>/) {
    my @fields = split(/\$\$/, $line);
    my @f1 = split(/:/, $fields[1]);
    my @f2 = split(/:/, $fields[2]);
    my $start = $f1[1];
    my $stop = $f2[1];
    my ($func_idx, $func_ptr) = &lookup($start, \%func_lookup);
    if ($func_idx != -1) {
      if (exists $func_ptr->{'TOUCHED'}) {
        die "" if ($file_content[$start-1] ne ">" or $file_content[$start-2] ne "-");
        die "" if $file_content[$stop+1] ne "[";
        my ($array_idx, $array_idx_start, $array_idx_stop) = &GetContentWithArrayBound($stop+2);
        die "" if $file_content[$array_idx_stop+1] ne "]";
        my %info = ();
        $info{'START'} = $start-2;
        $info{'STOP'} = $array_idx_stop+1;
        if (not exists $func_ptr->{'VECX'}) {
          my %vecx_info = ();
          $func_ptr->{'VECX'} = \%vecx_info;
        }
        $func_ptr->{'VECX'}->{$info{'START'}} = \%info;
      }
    }
  }
}
close FD;

foreach my $f (keys %funcs) {
  if (not exists $fp_helpers{$f}) {
    next;
  }
  my $has_foreign_call = 0;
  if (exists $funcs{$f}->{'IS_FOREIGN'}) {
    $has_foreign_call = 1;
  }
  # Collect dependent functions
  my @sub_call_stack = ();
  my %defined_func = ();
  # Assume no infinite recursive calls for path_info
  my %path_info = ();
  my @label_info = ();
  my %foreign_calls = ();
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
    } elsif (&FuncNameIsForeign($call_target)) {
      # Skip if the call target is a function pointer parameter of the current function
      my $is_param = 0;
      foreach my $arg (@{$funcs{$f}->{'SCALAR_ARGS'}}) {
        if ($arg->{'VAR_NAME'} eq $call_target) {
          $is_param = 1;
          last;
        }
      }
      if (!$is_param) {
        $foreign_calls{$call_target} = $func_type_input{$call_target};
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
        } elsif (&FuncNameIsForeign($call_target)) {
          # Skip if the call target is a function pointer parameter of the caller ($c)
          my $is_param = 0;
          if (exists $funcs{$c}) {
            foreach my $arg (@{$funcs{$c}->{'SCALAR_ARGS'}}) {
              if ($arg->{'VAR_NAME'} eq $call_target) {
                $is_param = 1;
                last;
              }
            }
          }
          if (!$is_param) {
            $foreign_calls{$call_target} = $func_type_input{$call_target};
          }
        }
      }
    }
    @sub_call_stack = @new_call_stack;
  }

  # Update REG references
  foreach my $sf (keys %defined_func) {
    &add_reg_references_on_execution_path($sf, \%defined_func);
  }

  # Standalone references to cc_src/cc_op/REG need pass through all intermediate function calls
  foreach my $sf (keys %defined_func) {
    &populate_additional_arguments_on_execution_path($sf, \%defined_func);
  }

  #if ($has_foreign_call) {
  #  print "$f\n";
  #}

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
  my %foreign_types = ();
  foreach my $ff (keys %foreign_calls) {
    my $type_name = $foreign_calls{$ff};
    $type_name =~ s/\s+/_/g;
    $foreign_types{$foreign_calls{$ff}} = $type_name;
  }
  print OUT "typedef __attribute__((qemuaot)) void (*FUNC_NORMAL_RET)(";
  foreach my $idx (0 .. $#qemuaot_gp_params) {
    my $p = $qemuaot_gp_params[$idx];
    if ($idx != $#qemuaot_gp_params) {
      print OUT "$qemuaot_gp_params_map{$p} $p, ";
    } else {
      print OUT "$qemuaot_gp_params_map{$p} $p ";
    }
  }
  print OUT "$qemuaot_vec_declare";
  if ($funcs{$f}->{'FUNC_TYPE'} ne "void") {
    print OUT ", $funcs{$f}->{'FUNC_TYPE'} ret_val";
  }
  print OUT ");\n";
  if (keys %foreign_types > 0) {
    print OUT "typedef __attribute__((qemuaot,noreturn)) void (*FUNC_EXCEPTION_RET)(";
    foreach my $idx (0 .. $#qemuaot_gp_params) {
      my $p = $qemuaot_gp_params[$idx];
      if ($idx != $#qemuaot_gp_params) {
        print OUT "$qemuaot_gp_params_map{$p} $p, ";
      } else {
        print OUT "$qemuaot_gp_params_map{$p} $p ";
      }
    }
    print OUT "$qemuaot_vec_declare";
    my $func_ptr = $funcs{$f};
    foreach my $si (@{$func_ptr->{'SCALAR_ARGS'}}) {
      print OUT ", unsigned long $si->{'VAR_NAME'}";
    }
    my $total_arg_cnt = $#{$func_ptr->{'SCALAR_ARGS'}} + $#{$func_ptr->{'VECTOR_ARGS'}} + 2;
    die "" if $total_arg_cnt > 6;
    if ($total_arg_cnt < 6) {
      print OUT ", unsigned long func_secondary);\n";
    } else {
      print OUT ");\n";
    }
  }
  my %order_to_func = ();
  foreach my $sf (keys %defined_func) {
    $order_to_func{$funcs{$sf}->{'FUNC_IDX'}} = $sf;
  }
  my @sorted_funcs = sort {$a <=> $b} keys %order_to_func;
  foreach my $s (@sorted_funcs) {
    my $func_name = $order_to_func{$s};
    my $new_func = &gen_replicated_func($func_name, \%defined_func, $f, \%foreign_calls, \%order_to_func);
    print OUT "$new_func";
  }

  close OUT;

  # FIXME: do check EXCEPTION paths have all been covered
  my $check_body = "";
  my $check_on = 0;
  open IN, "< $path/$f.c" or die "Cannot open $path/$f.c for read!\n";
  while (<IN>) {
    my $line = $_;
    chomp($line);
    if ($line =~ /QEMU_HELPER_BEGIN/) {
      $check_on = 1;
    }
    if ($check_on) {
      $check_body = $check_body."$line\n";
    }
  }
  close IN;
  foreach my $ff (keys %foreign_calls) {
    die "$ff" if $check_body =~ /([^a-zA-Z_0-9])${ff}([^a-zA-Z_0-9])/;
  }
}

sub lookup
{
  my ($loc, $lookup_info) = @_;
  my $low_idx = 0;
  my $high_idx = $#{$lookup_info->{'SORTED_ADDR'}};
  if ($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]}->{'LOOKUP_START'} <= $loc) {
    return ($high_idx, $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]});
  }
  while (($high_idx - $low_idx) > 1) {
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
  if ($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]}->{'LOOKUP_START'} < $loc and $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]}->{'LOOKUP_STOP'} > $loc) {
    return ($low_idx, $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$low_idx]});
  } elsif ($lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]}->{'LOOKUP_START'} < $loc and $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]}->{'LOOKUP_STOP'} > $loc) {
    return ($high_idx, $lookup_info->{'MAP'}->{$lookup_info->{'SORTED_ADDR'}->[$high_idx]});
  }
  return -1;
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
  my $func_type_info = $head;
  $func_type_info = &remove_attribute($func_type_info);
  $func_type_info =~ s/^\s*//;
  my $func_type = "NA";
  if (exists $fp_helpers{$func->{'NAME'}}) {
    my @type_fields = split(/\s+/, $func_type_info);
    my @sub_type_fields = @type_fields[0..($#type_fields-1)];
    $func_type = join(" ", @sub_type_fields);
  }
  my $head_copy = $head;
  if (not $head_copy =~ /__attribute__\(\(always_inline\)\)/) {
    $head_copy = "__attribute__((always_inline,weak)) ".$head_copy;
    # disable inline for debug
    #$head_copy = "__attribute__((noinline,weak)) ".$head_copy;
  } elsif (not $head_copy =~ /__attribute__\(\(weak\)\)/) {
    $head_copy = "__attribute__((weak)) ".$head_copy;
  }
  $head_copy =~ s/__attribute__\(\(target\(\"\+crypto\"\)\)\)//g;
  $head_copy =~ s/__attribute__\s*\(\s*\(\s*noinline\s*\)\s*\)//g;
  if (not exists $fp_helpers{$func->{'NAME'}}) {
    if ($head_copy =~ /static\s+/) {
      $head_copy =~ s/static\s+//;
    }
  } else {
    $head_copy =~ s/$func->{'NAME'}/HELPER_NAME/;
  }
  $head_copy = "__attribute__((qemuaot)) ".$head_copy;
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
    $ret128_info{'RETURN128'} = $sym;
    $head_copy =~ s/$sym/v2ulong/;
  } else {
    $ret128_info{'RETURN128'} = "";
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
    return ($head_copy, \@scalar, \@vector, $pure_arg_info, \%ret128_info, $env_type, $func_type);
  } else {
    my @empty = ();
    return ($head_copy, \@empty, \@empty, $pure_arg_info, \%ret128_info, $env_type, $func_type);
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

sub remove_attribute
{
  my ($str) = @_;
  while ($str =~ /^\s*__attribute__/) {
    my @chars = split(//, $str);
    my $idx = 0;
    my $paren_cnt = 0;
    while ($idx <= $#chars) {
      if ($chars[$idx] eq ")") {
        $paren_cnt = $paren_cnt - 1;
        if ($paren_cnt == 0) {
          last;
        }
      } elsif ($chars[$idx] eq "(") {
        $paren_cnt = $paren_cnt + 1;
      }
      $idx = $idx + 1;
    }
    $idx = $idx + 1;
    my @sub_chars = @chars[$idx..$#chars];
    $str = join("", @sub_chars);
    $str =~ s/^\s+//;
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
  my ($target_func, $func_replicate_info, $exception_exit, $fc, $order_to_func) = @_;
  my $new_func = "";
  if ($funcs{$target_func}->{'DO_EXPAND'} == 0) {
    die "" if not exists $func_replicate_info->{$target_func};
    die "" if keys %{$func_replicate_info->{$target_func}} == 0;
    my $new_head = $funcs{$target_func}->{'HEAD'};
    my $args = &collect_func_args($funcs{$target_func});
    my $current_func = $new_head."($args)\n";
    if ($funcs{$target_func}->{'HELPER_INTERFACE'}) {
      foreach my $vec_idx (0..$#{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
        my $arg_entry = $funcs{$target_func}->{'VECTOR_ARGS'}->[$vec_idx];
        $current_func = $current_func."#define $arg_entry->{'VAR_NAME'} VEC$vec_idx\n";
      }
    }
    my %empty = ();
    my @pis = keys %{$func_replicate_info->{$target_func}};
    if ($target_func eq $exception_exit) {
      &gen_restore_info($target_func, $order_to_func);
    }
    my $new_func_body = &get_func_body($funcs{$target_func}, $pis[0], \%empty, $exception_exit, $fc);
    if ($target_func eq $exception_exit) {
      $new_func_body = &add_context_backup($new_func_body, $target_func, $order_to_func);
    }
    $current_func = $current_func.$new_func_body."\n";
    if ($funcs{$target_func}->{'HELPER_INTERFACE'}) {
      foreach my $vec_idx (0..$#{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
        my $arg_entry = $funcs{$target_func}->{'VECTOR_ARGS'}->[$vec_idx];
        $current_func = $current_func."#undef $arg_entry->{'VAR_NAME'}\n";
      }
    }
    $new_func = $new_func.$current_func;
    $new_func = $new_func."\n";
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
        my $scalar_idx = &get_scalar_arg_idx($funcs{$target_func}, $var);
        die "" if $scalar_idx == -1;
        die "" if $#{$func_replicate_info->{$target_func}->{$pi}} == -1;
        my $in = $func_replicate_info->{$target_func}->{$pi}->[$#{$func_replicate_info->{$target_func}->{$pi}}];
        $macro_def{$var} = $funcs{$in->{'FUNC'}}->{'CALLS'}->{$in->{'LOC'}}->{'SCALAR_CALL_ARGS'}->[$scalar_idx];
      }
      if ($funcs{$target_func}->{'HELPER_INTERFACE'}) {
        foreach my $vec_idx (0..$#{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
          my $arg_entry = $funcs{$target_func}->{'VECTOR_ARGS'}->[$vec_idx];
          $current_func = $current_func."#define $arg_entry->{'VAR_NAME'} VEC$vec_idx\n";
        }
      }
      if ($target_func eq $exception_exit) {
        &gen_restore_info($target_func, $order_to_func);
      }
      my $new_func_body = &get_func_body($funcs{$target_func}, $pi, \%macro_def, $exception_exit, $fc);
      if ($target_func eq $exception_exit) {
        $new_func_body = &add_context_backup($new_func_body, $order_to_func);
      }
      $current_func = $current_func.$new_func_body."\n";
      $new_func = $new_func.$current_func;
      # Un-define arguments
      if ($funcs{$target_func}->{'HELPER_INTERFACE'}) {
        foreach my $vec_idx (0..$#{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
          my $arg_entry = $funcs{$target_func}->{'VECTOR_ARGS'}->[$vec_idx];
          $current_func = $current_func."#undef $arg_entry->{'VAR_NAME'}\n";
        }
      }
      $new_func = $new_func."\n";
    }
  }
  return $new_func;
}

sub gen_restore_info
{
  my ($target_func, $order_to_func) = @_;
  my %backups = ();
  my %restore_info = ();
  my $need_env = 0;
  foreach my $ok (keys %{$order_to_func}) {
    foreach my $bv (keys %{$funcs{$order_to_func->{$ok}}->{'ENVVAR_AND_VECTORS'}}) {
      $backups{$bv} = 1;
      if ($bv =~ /^env/) {
        $need_env = 1;
      }
    }
  }
  foreach my $bk (keys %backups) {
    if ($bk =~ /^xmm/) {
      $restore_info{"backup_$bk"} = $bk;
    } else {
      die "$bk" if (not exists $qemuaot_gp_params_map{$bk});
      my $var_name = $bk;
      if ($var_name =~ /^env/) {
        my $short_name = $var_name;
        $short_name =~ s/^env\-\>//;
        $restore_info{"backup_$short_name"} = $bk;
      } else {
        $restore_info{"backup_$var_name"} = $bk;
      }
    }
  }
  if (exists $funcs{$target_func}->{'IS_FOREIGN'}) {
    foreach my $v (@{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
      $restore_info{"backup_$v->{'VAR_NAME'}"} = $v->{'VAR_NAME'};
    }
  }
  $funcs{$target_func}->{'RESTORE_INFO'} = \%restore_info;
}

sub add_context_backup
{
  my ($new_func_body, $target_func, $order_to_func) = @_;
  my %backups = ();
  my %restore_info = ();
  my $need_env = 0;
  foreach my $ok (keys %{$order_to_func}) {
    foreach my $bv (keys %{$funcs{$order_to_func->{$ok}}->{'ENVVAR_AND_VECTORS'}}) {
      $backups{$bv} = 1;
      if ($bv =~ /^env/) {
        $need_env = 1;
      }
    }
  }
  my $backup_vars = "";
  if (exists $funcs{$target_func}->{'IS_FOREIGN'}) {
    $backup_vars = $backup_vars."int trigger_exception = 0;\n";
  }
  if ($need_env or exists $funcs{$target_func}->{'DO_DEFINE_ENV'}) {
    $backup_vars = $backup_vars."CPUX86State *env;\n";
    if ($arch_info eq "riscv64") {
      $backup_vars = $backup_vars."asm volatile (\"mv %0, x25\" : \"=r\" (env) : :);\n";
    } else {
      $backup_vars = $backup_vars."asm volatile (\"mov %0, x25\" : \"=r\" (env) : :);\n";
    }
  }
  foreach my $bk (keys %backups) {
    if ($bk =~ /^xmm/) {
      $backup_vars = $backup_vars."v2ulong backup_$bk = $bk;\n";
      $restore_info{"backup_$bk"} = $bk;
    } else {
      die "$bk" if (not exists $qemuaot_gp_params_map{$bk});
      my $var_name = $bk;
      $var_name =~ s/^env\-\>//;
      my $type_info = "";
      if (exists $qemuaot_gp_params_map{$bk}) {
        $type_info = $qemuaot_gp_params_map{$bk};
      } elsif ($bk eq "env->cc_op") {
        $type_info = "unsigned int";
      } elsif ($bk eq "env->cc_src") {
        $type_info = "unsigned long";
      } elsif ($bk eq "env->cc_dst") {
        $type_info = "unsigned long";
      } else {
        die "";
      }
      $backup_vars = $backup_vars."$type_info backup_$var_name = $bk;\n";
      $restore_info{"backup_$var_name"} = $bk;
    }
  }
  if (exists $funcs{$target_func}->{'IS_FOREIGN'}) {
    foreach my $v (@{$funcs{$target_func}->{'VECTOR_ARGS'}}) {
      $backup_vars = $backup_vars."v2ulong backup_$v->{'VAR_NAME'} = $v->{'VAR_NAME'};\n";
      $restore_info{"backup_$v->{'VAR_NAME'}"} = $v->{'VAR_NAME'};
    }
  }
  foreach my $si (@{$funcs{$target_func}->{'SCALAR_ARGS'}}) {
    $backup_vars = $backup_vars."$si->{'TYPE'} backup_$si->{'VAR_NAME'} = $si->{'VAR_NAME'};\n";
  }
  $backup_vars = $backup_vars."\n";
  $new_func_body =~ s/^\{/\{\n$backup_vars/;
  return $new_func_body;
}

sub get_func_body
{
  my ($func_ptr, $pi, $md, $exception_exit, $fc) = @_;
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
  foreach my $e (keys %{$func_ptr->{'VECX'}}) {
    $events{$e} = 1;
  }
  foreach my $e (keys %{$func_ptr->{'RETURNS'}}) {
    if ($func_ptr->{'RETURNS'}->{$e}->{'TYPE'} eq "RETURN_EXPR") {
      $events{$e} = 1;
    }
  }
  if ($func_ptr->{'HELPER_INTERFACE'}) {
    foreach my $e (keys %{$func_ptr->{'RETURNS'}}) {
      $events{$e} = 1;
    }
  }
  my @sorted_events = sort {$a <=> $b} keys %events;
  my $current_pos;
  my $body = "";
  if (exists $func_ptr->{'DO_DEFINE_ENV'} and $func_ptr->{'NAME'} ne $exception_exit) {
    $body = "{\n";
    $body = $body."   $func_ptr->{'ENV_TYPE'}env;\n";
    if ($arch_info eq "riscv64") {
      $body = $body."   asm volatile (\"mv %0, x25\" : \"=r\" (env) : :);\n";
    } else {
      $body = $body."   asm volatile (\"mov %0, x25\" : \"=r\" (env) : :);\n";
    }
  } else {
    $body = "{\n";
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      my $counter_def = <<~'END';
#ifdef HELPER_COUNTERS
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    unsigned long env_val;
    asm volatile ("mov %0, x25" : "=r" (env_val) : :);
    unsigned long *helper1_cnt_ptr = (unsigned long *)(env_val - 88);
    *helper1_cnt_ptr += 1;
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    unsigned long env_val;
    asm volatile ("mv %0, x25" : "=r" (env_val) : :);
    unsigned long *helper1_cnt_ptr = (unsigned long *)(env_val - 88);
    *helper1_cnt_ptr += 1;
#endif
#endif
END
      $body = $body.$counter_def;
    }
  }
  $current_pos = $func_ptr->{'BODY_START'} + 1;
  foreach my $e (@sorted_events) {
    if ($e < $current_pos) {
      next;
    }
    if ($e != $current_pos) {
      my $txt = &GetText($current_pos, ($e - 1));
      $body = $body.$txt;
    }
    if (exists $func_ptr->{'CALLS'}->{$e}) {
      my $call_target = $func_ptr->{'CALLS'}->{$e}->{'CALL_TARGET'};
      if (not exists $funcs{$call_target}) {
        if (&FuncNameIsForeign($call_target)) {
          # Skip if the call target is a function pointer parameter of the current function
          my $is_param = 0;
          foreach my $arg (@{$func_ptr->{'SCALAR_ARGS'}}) {
            if ($arg->{'VAR_NAME'} eq $call_target) {
              $is_param = 1;
              last;
            }
          }
          if ($is_param) {
            # Emit the original call text unchanged
            $body = $body . &GetText(
                $func_ptr->{'CALLS'}->{$e}->{'NAME_START'},
                $func_ptr->{'CALLS'}->{$e}->{'PAREN_STOP'}
            );
            $current_pos = $func_ptr->{'CALLS'}->{$e}->{'PAREN_STOP'} + 1;
          } else {
            die "$call_target" if not exists $fc->{$call_target};
            my $type_name = $fc->{$call_target};
            $type_name =~ s/\s+/_/g;
            if ($func_ptr->{'HELPER_INTERFACE'}) {
              $body = $body."($type_name)(trigger_exception = 1)";
            } else {
              $body = $body."($type_name)(*trigger_exception_ptr = 1)";
            }
            $current_pos = $func_ptr->{'CALLS'}->{$e}->{'PAREN_STOP'} + 1;
          }
        } else {
          $current_pos = $e;
        }
      } else {
        if ($funcs{$call_target}->{'128'}->{'RETURN128'} ne "") {
          $body = $body."($funcs{$call_target}->{'128'}->{'RETURN128'})";
        }
        my $call_txt = &update_func_call($func_ptr, $e, $funcs{$call_target}, $pi, $fc);
        $body = $body.$call_txt;
        $current_pos = $func_ptr->{'CALLS'}->{$e}->{'PAREN_STOP'} + 1;
      }
    } elsif (exists $func_ptr->{'VEC'}->{$e}) {
      if ($func_ptr->{'VEC'}->{$e}->{'FROM_PARAM'}) {
        if ($func_ptr->{'HELPER_INTERFACE'}) {
          $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$e}->{'TYPE'}})$func_ptr->{'VECTOR_ARGS'}->[$func_ptr->{'VEC'}->{$e}->{'VAR'}]->{'VAR_NAME'})";
        } else {
          $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$e}->{'TYPE'}})(*$func_ptr->{'VECTOR_ARGS'}->[$func_ptr->{'VEC'}->{$e}->{'VAR'}]->{'VAR_NAME'}))";
        }
        $current_pos = $func_ptr->{'VEC'}->{$e}->{'STOP'} + 1;
      } else {
        $body = $body."(($VecCodeToCType{$func_ptr->{'VEC'}->{$e}->{'TYPE'}})$func_ptr->{'VEC'}->{$e}->{'VAR'})";
        $current_pos = $func_ptr->{'VEC'}->{$e}->{'STOP'} + 1;
      }
    } elsif (exists $func_ptr->{'VEC_VAR'}->{$e}) {
      my $entry = $func_ptr->{'VEC_VAR'}->{$e};
      if ($func_ptr->{'HELPER_INTERFACE'}) {
        $body = $body."v2ulong ".$entry->{'SYM'}." = ".$func_ptr->{'VECTOR_ARGS'}->[$entry->{'VEC_ARG_IDX'}]->{'VAR_NAME'};
      } else {
        $body = $body."v2ulong ".$entry->{'SYM'}." = *".$func_ptr->{'VECTOR_ARGS'}->[$entry->{'VEC_ARG_IDX'}]->{'VAR_NAME'};
      }
      $current_pos = $entry->{'STOP'} + 1;
    } elsif (exists $func_ptr->{'ENV'}->{$e}) {
      my $entry = $func_ptr->{'ENV'}->{$e};
      if ($entry->{'GET_ADDRESS'}) {
        $current_pos = $e;
      } else {
        my $new_var = &replace_env_var($entry, $md, $func_ptr);
        if ($new_var ne "") {
          $body = $body.$new_var;
          $current_pos = $entry->{'STOP'} + 1;
        } else {
          $current_pos = $e;
        }
      }
    } elsif (exists $func_ptr->{'VEC_ASSIGN'}->{$e}) {
      my $vec_entry = $func_ptr->{'VEC_ASSIGN'}->{$e}->{'VEC_INFO'};
      my $vec_var = "";
      if ($vec_entry->{'FROM_PARAM'}) {
        if ($func_ptr->{'HELPER_INTERFACE'}) {
          $vec_var = $func_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'};
        } else {
          $vec_var = "(*".$func_ptr->{'VECTOR_ARGS'}->[$vec_entry->{'VAR'}]->{'VAR_NAME'}.")";
        }
      } else {
        $vec_var = $vec_entry->{'VAR'};
      }
      if ($vec_entry->{'TYPE'} eq "VecQ") {
        $body = $body.$vec_var;
        $current_pos = $vec_entry->{'STOP'} + 1;
      } else {
        $body = $body."{\n";
        $body = $body."$VecCodeToCType{$vec_entry->{'TYPE'}} vec_assign_tmp = ($VecCodeToCType{$vec_entry->{'TYPE'}})$vec_var;\n";
        $body = $body."vec_assign_tmp[".$vec_entry->{'DEF_SYM_INFO'}->[$#{$vec_entry->{'DEF_SYM_INFO'}}]->{'ARRAY_IDX'}."] ";
        my $sub_head = $func_ptr->{'VEC_ASSIGN'}->{$e}->{'ASSIGN_POS'};
        my $sub_current = $sub_head;
        while ($sub_current != $func_ptr->{'VEC_ASSIGN'}->{$e}->{'SEMI_POS'}) {
          if (exists $func_ptr->{'CALLS'}->{$sub_current} and exists $funcs{$func_ptr->{'CALLS'}->{$sub_current}->{'CALL_TARGET'}}) {
            my $sub_str = &GetText($sub_head, ($sub_current-1));
            $body = $body.$sub_str;
            my $func_call_str = &update_func_call($func_ptr, $sub_current, $funcs{$func_ptr->{'CALLS'}->{$sub_current}->{'CALL_TARGET'}}, $pi, $fc);
            $body = $body.$func_call_str;
            $sub_head = $func_ptr->{'CALLS'}->{$sub_current}->{'PAREN_STOP'} + 1;
            $sub_current = $sub_head;
          } elsif (exists $func_ptr->{'CALLS'}->{$sub_current} and &FuncNameIsForeign($func_ptr->{'CALLS'}->{$sub_current}->{'CALL_TARGET'})) {
            my $sub_str = &GetText($sub_head, ($sub_current-1));
            $body = $body.$sub_str;
            my $foreign_call = $func_ptr->{'CALLS'}->{$sub_current}->{'CALL_TARGET'};
            # Skip if the call target is a function pointer parameter of the current function
            my $is_param = 0;
            foreach my $arg (@{$func_ptr->{'SCALAR_ARGS'}}) {
                if ($arg->{'VAR_NAME'} eq $foreign_call) {
                    $is_param = 1;
                    last;
                }
            }
            if ($is_param) {
                # Emit the original call text unchanged
                $body = $body.&GetText($func_ptr->{'CALLS'}->{$sub_current}->{'NAME_START'}, $func_ptr->{'CALLS'}->{$sub_current}->{'PAREN_STOP'});
            } else {
                die "" if not exists $fc->{$foreign_call};
                if ($func_ptr->{'HELPER_INTERFACE'}) {
                    $body = $body."($fc->{$foreign_call})(trigger_exception = 1)";
                } else {
                    $body = $body."($fc->{$foreign_call})(*trigger_exception_ptr = 1)";
                }
            }
            $sub_head = $func_ptr->{'CALLS'}->{$sub_current}->{'PAREN_STOP'} + 1;
            $sub_current = $sub_head;
          } elsif (exists $func_ptr->{'VEC'}->{$sub_current}) {
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
        $body = $body."\n$vec_var = (v2ulong)vec_assign_tmp;\n";
        $body = $body."}\n";
        $current_pos = $sub_current + 1;
      }
    } elsif (exists $func_ptr->{'VECX'}->{$e}) {
      $current_pos = $func_ptr->{'VECX'}->{$e}->{'STOP'} + 1;
    } elsif (exists $func_ptr->{'RETURNS'}->{$e}) {
      my $ret_info = $func_ptr->{'RETURNS'}->{$e};
      if ($func_ptr->{'128'}->{'RETURN128'} ne "") {
        die "" if $func_ptr->{'HELPER_INTERFACE'};
        my $sub_str = &GetText($e, $ret_info->{'EXPR_START'}-1);
        $body = $body.$sub_str."(v2ulong)";
        $current_pos = $ret_info->{'EXPR_START'};
      } elsif ($func_ptr->{'HELPER_INTERFACE'}) {
        if (exists $func_ptr->{'IS_FOREIGN'}) {
          $body = $body."{\n";
          my $exp = &get_exception_path($func_ptr, $exception_exit);
          $body = $body.$exp;
          if ($func_ptr->{'RETURNS'}->{$e}->{'TYPE'} eq "RETURN_VOID") {
            $body = $body."return ((FUNC_NORMAL_RET)normal_return)(";
            foreach my $p (@qemuaot_gp_params) {
              $body = $body."$p, ";
            }
            $body =~ s/,\s+$/ /;
            $body = $body.$qemuaot_vec_invoke.");\n}\n";
            $current_pos = $func_ptr->{'RETURNS'}->{$e}->{'RETURN_STOP'} + 2;
          } else {
            my $expr = &GetText($func_ptr->{'RETURNS'}->{$e}->{'EXPR_START'}, $func_ptr->{'RETURNS'}->{$e}->{'EXPR_STOP'});
            $body = $body."return ((FUNC_NORMAL_RET)normal_return)(";
            foreach my $p (@qemuaot_gp_params) {
              $body = $body."$p, ";
            }
            $body =~ s/,\s+$/ /;
            $body = $body.$qemuaot_vec_invoke.", $expr);\n}\n";
            $current_pos = $func_ptr->{'RETURNS'}->{$e}->{'EXPR_STOP'} + 2;
          }
        } else {
          if ($func_ptr->{'RETURNS'}->{$e}->{'TYPE'} eq "RETURN_VOID") {
            $body = $body."return ((FUNC_NORMAL_RET)normal_return)(";
            foreach my $p (@qemuaot_gp_params) {
              $body = $body."$p, ";
            }
            $body =~ s/,\s+$/ /;
            $body = $body.$qemuaot_vec_invoke.");\n";
            $current_pos = $func_ptr->{'RETURNS'}->{$e}->{'RETURN_STOP'} + 2;
          } else {
            my $expr = &GetText($func_ptr->{'RETURNS'}->{$e}->{'EXPR_START'}, $func_ptr->{'RETURNS'}->{$e}->{'EXPR_STOP'});
            $body = $body."return ((FUNC_NORMAL_RET)normal_return)(";
            foreach my $p (@qemuaot_gp_params) {
              $body = $body."$p, ";
            }
            $body =~ s/,\s+$/ /;
            $body = $body.$qemuaot_vec_invoke.", $expr);\n";
            $current_pos = $func_ptr->{'RETURNS'}->{$e}->{'EXPR_STOP'} + 2;
          }
        }
      } else {
        $current_pos = $e;
      }
    } else {
      die "";
    }
  }
  my $txt = &GetText($current_pos, $func_ptr->{'BODY_STOP'});
  $body = $body.$txt;
  if ($func_ptr->{'HELPER_INTERFACE'} and $func_ptr->{'FUNC_TYPE'} eq "void") {
    my $exp_logic = "";
    if (exists $func_ptr->{'IS_FOREIGN'}) {
      $exp_logic = &get_exception_path($func_ptr, $exception_exit);
    }
    my $normal_logic = "";
    $normal_logic = $normal_logic."return ((FUNC_NORMAL_RET)normal_return)(";
    foreach my $p (@qemuaot_gp_params) {
      $normal_logic = $normal_logic."$p, ";
    }
    $normal_logic =~ s/,\s+$/ /;
    $normal_logic = $normal_logic.$qemuaot_vec_invoke.");\n";
    $body =~ s/\}$/\n$exp_logic$normal_logic\}/;
  }
  return $body;
}

sub get_exception_path
{
  my ($func_ptr, $exception_exit) = @_;
  my $body = "";
  $body = $body."if (trigger_exception) {\n";
  foreach my $rk (keys %{$func_ptr->{'RESTORE_INFO'}}) {
    $body = $body."  $func_ptr->{'RESTORE_INFO'}->{$rk} = $rk;\n";
  }
  $body = $body."  return ((FUNC_EXCEPTION_RET)exception_return)(";
  foreach my $p (@qemuaot_gp_params) {
    $body = $body."$p, ";
  }
  $body =~ s/,\s+$/ /;
  $body = $body.$qemuaot_vec_invoke;
  foreach my $si (@{$func_ptr->{'SCALAR_ARGS'}}) {
    $body = $body.", backup_$si->{'VAR_NAME'}";
  }
  my $total_arg_cnt = $#{$func_ptr->{'SCALAR_ARGS'}} + $#{$func_ptr->{'VECTOR_ARGS'}} + 2;
  die "" if $total_arg_cnt > 6;
  if ($total_arg_cnt < 6) {
    $body = $body.", (unsigned long)normal_return);\n";
  } else {
    $body = $body.");\n";
  }
  $body = $body."}\n";
  return $body;
}

sub update_func_call
{
  my ($caller_ptr, $call_pos, $callee_ptr, $path_info, $fc) = @_;
  my $call_info = $caller_ptr->{'CALLS'}->{$call_pos};
  my $str = "";
  if ($callee_ptr->{'DO_EXPAND'}) {
    $str = $callee_ptr->{'NAME'}."_".$path_info."_".$caller_ptr->{'NAME'}."_loc".$call_pos;
  } else {
    $str = $callee_ptr->{'NAME'};
  }
  $str = $str."(";
  my $call_list = "";
  my $prefix = "";
  my $postfix = "";
  if ($caller_ptr->{'HELPER_INTERFACE'}) {
    $prefix = "&";
  } else {
    $postfix = "_ptr";
  }
  my @sorted_keys = sort {$a cmp $b} keys %{$callee_ptr->{'ENVVAR_AND_VECTORS'}};
  foreach my $sk (@sorted_keys) {
    if ($sk =~ /^env\-\>/) {
      next;
    }
    $call_list = $call_list.", $prefix$sk$postfix";
  }
  foreach my $vec_arg (@{$call_info->{'VECTOR_CALL_ARGS'}}) {
    $call_list = $call_list.", $prefix$vec_arg";
  }
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
    if ($arg =~ /\(/ and (not $arg =~ /^(\-|sizeof)?\(/)) {
      die "" if not $arg =~ /\)/;
      die "$caller_ptr->{'NAME'} $callee_ptr->{'NAME'}" if not exists $sorted_sub_calls[$sub_call_idx];
      my $sub_call_info = $caller_ptr->{'CALLS'}->{$sorted_sub_calls[$sub_call_idx]};
      if (exists $funcs{$sub_call_info->{'CALL_TARGET'}}) {
        my $sub_call_txt = &update_func_call($caller_ptr, $sorted_sub_calls[$sub_call_idx], $funcs{$sub_call_info->{'CALL_TARGET'}}, $path_info, $fc);
        $call_list = $call_list.", ".$sub_call_txt;
      } elsif (&FuncNameIsForeign($sub_call_info->{'CALL_TARGET'})) {
        # Skip if the call target is a function pointer parameter of the caller
        my $is_param = 0;
        foreach my $arg (@{$caller_ptr->{'SCALAR_ARGS'}}) {
            if ($arg->{'VAR_NAME'} eq $sub_call_info->{'CALL_TARGET'}) {
                $is_param = 1;
                last;
            }
        }
        if ($is_param) {
            # Keep the original call text unchanged
            $call_list = $call_list.", ".&GetText($sub_call_info->{'NAME_START'}, $sub_call_info->{'PAREN_STOP'});
        } else {
            die "" if not exists $fc->{$sub_call_info->{'CALL_TARGET'}};
            my $sub_call_txt = "";
            if ($caller_ptr->{'HELPER_INTERFACE'}) {
                $sub_call_txt = "($fc->{$sub_call_info->{'CALL_TARGET'}})(trigger_exception = 1)";
            } else {
                $sub_call_txt = "($fc->{$sub_call_info->{'CALL_TARGET'}})(*trigger_exception_ptr = 1)";
            }
            $call_list = $call_list.", ".$sub_call_txt;
        }
      } else {
        my $param = &update_vector_inside_single_param($caller_ptr, $call_info, $idx, $arg);
        $call_list = $call_list.", ".$param;
      }
      $sub_call_idx = $sub_call_idx + 1;
    } else {
      my $param = &update_vector_inside_single_param($caller_ptr, $call_info, $idx, $arg);
      $call_list = $call_list.", ".$param;
    }
  }
  if ($callee_ptr->{'IS_FOREIGN'}) {
    if ($caller_ptr->{'HELPER_INTERFACE'}) {
      $call_list = $call_list.", &trigger_exception";
    } else {
      die "" if (not exists $caller_ptr->{'IS_FOREIGN'});
      $call_list = $call_list.", trigger_exception_ptr";
    }
  }
  $call_list =~ s/^,\s+//;
  $str = $str.$call_list;
  $str = $str.")";
  return $str;
}

sub update_vector_inside_single_param
{
  my ($caller_ptr, $call_info, $idx, $arg) = @_;
  my $str = "";
  my $range_info = $call_info->{'SCALAR_CALL_ARG_RANGES'}->[$idx];
  my @vecs = ();
  foreach my $e (keys %{$caller_ptr->{'VEC'}}) {
    if ($e >= $range_info->{'START'} and $e < $range_info->{'STOP'}) {
      push @vecs, $e;
    }
  }
  if (@vecs != 0) {
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
    $str = $arg;
  }
  return $str;
}

sub collect_func_args
{
  my ($func_ptr) = @_;
  my $args = "";
  if ($func_ptr->{'HELPER_INTERFACE'}) {
    foreach my $g (@qemuaot_gp_params) {
      $args = $args.$qemuaot_gp_params_map{$g}." ".$g.", ";
    }
    $args =~ s/,\s+$/ /;
    $args = $args.$qemuaot_vec_declare;
  } else {
    my @sorted_keys = sort {$a cmp $b} keys %{$func_ptr->{'ENVVAR_AND_VECTORS'}};
    foreach my $sk (@sorted_keys) {
      if ($sk =~ /^env\-\>/) {
        next;
      }
      if ($sk =~ /^xmm/) {
        $args = $args.", v2ulong *".$sk."_ptr";
      } else {
        die "" if not exists $qemuaot_gp_params_map{$sk};
        $args = $args.", $qemuaot_gp_params_map{$sk} *".$sk."_ptr";
      }
    }
  }
  if ($func_ptr->{'HELPER_INTERFACE'} == 0) {
    foreach my $i (@{$func_ptr->{'VECTOR_ARGS'}}) {
      $args = $args.", v2ulong *".$i->{'VAR_NAME'};
    }
  }
  #if ($func_ptr->{'HELPER_INTERFACE'} and @{$func_ptr->{'SCALAR_ARGS'}} > 0) {
  #  print "$func_ptr->{'NAME'}";
  #}
  foreach my $i (@{$func_ptr->{'SCALAR_ARGS'}}) {
    $args = $args.", ".$i->{'TYPE'}." ".$i->{'VAR_NAME'};
    #if ($func_ptr->{'HELPER_INTERFACE'}) {
    #  print " $i->{'TYPE'}";
    #}
  }
  #if ($func_ptr->{'HELPER_INTERFACE'} and @{$func_ptr->{'SCALAR_ARGS'}} > 0) {
  #  print "\n";
  #}
  if ($func_ptr->{'HELPER_INTERFACE'}) {
    if (exists $func_ptr->{'IS_FOREIGN'}) {
      $args = $args.", unsigned long normal_return, unsigned long exception_return";
    } else {
      $args = $args.", unsigned long normal_return";
    }
  } elsif (exists $func_ptr->{'IS_FOREIGN'}) {
    $args = $args.", int *trigger_exception_ptr";
  }
  $args =~ s/^,\s+//;
  return $args;
}

# There could be function call within arguments
sub ExtractCallArguments
{
  my ($input, $start_idx, $stop_idx) = @_;
  my @output = ();
  my @comma_split_fields = split(/,/, $input);
  my @size_cnt = ();
  foreach my $csf (@comma_split_fields) {
    my @sub_fields = split(//, $csf);
    my $cnt = @sub_fields;
    push @size_cnt, $cnt;
  }
  my @range = ();
  my $range_start = $start_idx;
  my $comma_cnt = 0;
  my $comma_start = 0;
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
      my %r_info = ();
      $r_info{'START'} = $range_start;
      $r_info{'STOP'} = $stop_idx;
      push @range, \%r_info;
      last;
    }
    my ($sym, $sym_start, $sym_stop) = &GetSymbol(\@chars, $idx, 0);
    $idx = $sym_stop + 1;
    if ($idx > $#chars) {
      my @elems = @chars[$start_idx..$#chars];
      my $elem = join("", @elems);
      push @output, $elem;
      my %r_info = ();
      $r_info{'START'} = $range_start;
      $r_info{'STOP'} = $stop_idx;
      push @range, \%r_info;
      last;
    }
    while (1) {
      while ($chars[$idx] ne "(" and $chars[$idx] ne "{" and $chars[$idx] ne ",") {
        $idx = $idx + 1;
        if ($idx > $#chars) {
          last;
        }
      }
      if ($idx > $#chars) {
        my @elems = @chars[$start_idx..$#chars];
        my $elem = join("", @elems);
        push @output, $elem;
        my %r_info = ();
        $r_info{'START'} = $range_start;
        $r_info{'STOP'} = $stop_idx;
        push @range, \%r_info;
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
          } elsif ($chars[$idx] eq ",") {
            $comma_cnt = $comma_cnt + 1;
          }
        }
      } elsif ($chars[$idx] eq "{") {
        my $cnt = 1;
        while ($cnt != 0) {
          $idx = $idx + 1;
          die "" if ($idx > $#chars);
          if ($chars[$idx] eq "{") {
            $cnt = $cnt + 1;
          } elsif ($chars[$idx] eq "}") {
            $cnt = $cnt - 1;
          } elsif ($chars[$idx] eq ",") {
            $comma_cnt = $comma_cnt + 1;
          }
        }
      } elsif ($chars[$idx] eq ",") {
        my @elems = @chars[$start_idx..($idx-1)];
        my $elem = join("", @elems);
        push @output, $elem;
        my %r_info = ();
        $r_info{'START'} = $range_start;
        my $total_size_cnt = 0;
        foreach my $cc ($comma_start..$comma_cnt) {
          $total_size_cnt = $total_size_cnt + $size_cnt[$cc];
        }
        $total_size_cnt = $total_size_cnt + ($comma_cnt - $comma_start);
        $r_info{'STOP'} = $range_start + $total_size_cnt - 1;
        push @range, \%r_info;
        $comma_start = $comma_cnt + 1;
        $range_start = $r_info{'STOP'} + 2;
        last;
      } else {
        die "";
      }
    }
    if ($idx > $#chars) {
      last;
    }
    if ($chars[$idx] eq ",") {
      $comma_cnt = $comma_cnt + 1;
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

sub IsValidSymbol
{
  my ($str) = @_;
  my @chars = split(//, $str);
  foreach my $c (@chars) {
    if (not (("a" le $c and $c le "z") or
        ("A" le $c and $c le "Z") or
        ("0" le $c and $c le "9") or
        $c eq "_" or $c eq "*")) {
      return 0;
    }
  }
  return 1;
}

sub FuncNameIsForeign
{
  my ($func_name) = @_;
  if (exists $funcs{$func_name}) {
    return 0;
  } elsif ($func_name eq '_Generic') {
    return 0;
  } elsif ($func_name =~ /^__builtin_/ or $func_name =~ /^__atomic/) {
    return 0;
  } else {
    return 1;
  }
}

sub replace_env_var
{
  my ($entry, $md, $func_ptr) = @_;
  if ($#{$entry->{'DEF_SYM_INFO'}} == -1) {
    return "env";
  }
  my $new_var = "";
  if ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_src") {
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      $new_var = "qemuaot_src1";
    } else {
      $new_var = "(*qemuaot_src1_ptr)";
    }
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_dst") {
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      $new_var = "qemuaot_dst";
    } else {
      $new_var = "(*qemuaot_dst_ptr)";
    }
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "cc_op") {
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      $new_var = "qemuaot_op";
    } else {
      $new_var = "(*qemuaot_op_ptr)";
    }
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "regs") {
    die "" if $entry->{'DEF_SYM_INFO'}->[0]->{'IS_ARRAY'} == 0;
    my $reg_idx = $entry->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'};
    if (exists $md->{$reg_idx}) {
      $reg_idx = $md->{$reg_idx};
    }
    die "" if not exists $env_reg_idx_map{$reg_idx};
    die "" if not exists $func_ptr->{'ENVVAR_AND_VECTORS'}->{$env_reg_idx_map{$reg_idx}};
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      $new_var = $env_reg_idx_map{$reg_idx};
    } else {
      $new_var = "(*$env_reg_idx_map{$reg_idx}_ptr)";
    }
  } elsif ($entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "xmm_regs") {
    die "" if $entry->{'DEF_SYM_INFO'}->[0]->{'IS_ARRAY'} == 0;
    my $xmm_idx = $entry->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'};
    die "" if not exists $env_xmmregs_idx_map{$xmm_idx};
    die "" if $entry->{'DEF_SYM_INFO'}->[1]->{'IS_ARRAY'} == 0;
    my $vec_sym = $entry->{'DEF_SYM_INFO'}->[1]->{'SYM'};
    die "" if not exists $VecSymbolToCType{$vec_sym};
    my $vec_idx = $entry->{'DEF_SYM_INFO'}->[1]->{'ARRAY_IDX'};
    if ($func_ptr->{'HELPER_INTERFACE'}) {
      $new_var = "(($VecSymbolToCType{$vec_sym})$env_xmmregs_idx_map{$xmm_idx})[$vec_idx]";
    } else {
      die "";
    }
  }
  return $new_var;
}

sub add_reg_references_on_execution_path
{
  my ($target_func, $func_replicate_info) = @_;
  my %macro_def = ();
  foreach my $pi (keys %{$func_replicate_info->{$target_func}}) {
    foreach my $var (@{$funcs{$target_func}->{'EXPAND_FACTORS'}}) {
      my $scalar_idx = &get_scalar_arg_idx($funcs{$target_func}, $var);
      die "" if $scalar_idx == -1;
      die "" if $#{$func_replicate_info->{$target_func}->{$pi}} == -1;
      my $in = $func_replicate_info->{$target_func}->{$pi}->[$#{$func_replicate_info->{$target_func}->{$pi}}];
      $macro_def{$var} = $funcs{$in->{'FUNC'}}->{'CALLS'}->{$in->{'LOC'}}->{'SCALAR_CALL_ARGS'}->[$scalar_idx];
    }
    foreach my $e (keys %{$funcs{$target_func}->{'ENV'}}) {
      my $entry = $funcs{$target_func}->{'ENV'}->{$e};
      if (exists $entry->{'DEF_SYM_INFO'}->[0] and $entry->{'DEF_SYM_INFO'}->[0]->{'SYM'} eq "regs") {
        die "" if $entry->{'DEF_SYM_INFO'}->[0]->{'IS_ARRAY'} == 0;
        my $reg_idx = $entry->{'DEF_SYM_INFO'}->[0]->{'ARRAY_IDX'};
        if (exists $macro_def{$reg_idx}) {
          $reg_idx = $macro_def{$reg_idx};
        }
        die "" if not exists $env_reg_idx_map{$reg_idx};
        my $new_var = $env_reg_idx_map{$reg_idx};
        $funcs{$target_func}->{'ENVVAR_AND_VECTORS'}->{$new_var} = 1;
      }
    }
  }
}

sub populate_additional_arguments_on_execution_path
{
  my ($target_func, $func_replicate_info) = @_;
  my $target = $funcs{$target_func};
  foreach my $pi (keys %{$func_replicate_info->{$target_func}}) {
    foreach my $entry (@{$func_replicate_info->{$target_func}->{$pi}}) {
      my $intermediate = $funcs{$entry->{'FUNC'}};
      foreach my $v (keys %{$target->{'ENVVAR_AND_VECTORS'}}) {
        if ($v =~ /^env\-\>/) {
          next;
        }
        $intermediate->{'ENVVAR_AND_VECTORS'}->{$v} = 1;
      }
    }
  }
}

sub filter_blank_info {
  my ($blank_info, $covered_ref) = @_;
  my $cleaned = "";
  my @blank_lines = split(/\n/, $blank_info);
  my $remove_next = 0;
  foreach my $line (@blank_lines) {
    if ($line =~ /^#/) {
      $cleaned .= $line . "\n";
      next;
    }
    if ($remove_next) {
      if ($line =~ /;$/) {
        $remove_next = 0;
      }
      next;
    }
    if ($line =~ /;$/ and $line =~ /\(/) {
      my @fields = split(/\(/, $line);
      my $check = $fields[0];
      $check =~ s/\s+$//;
      if ($check =~ /\s/) {
        my @sub_fields = split(/\s+/, $check);
        my $ff_name = $sub_fields[$#sub_fields];
        if (exists $covered_ref->{$ff_name}) {
          #print "Removed $line\n";
          next;
        }
      }
    } elsif ($line =~ /,$/ and $line =~ /\(/) {
      my @fields = split(/\(/, $line);
      my $check = $fields[0];
      $check =~ s/\s+$//;
      if ($check =~ /\s/) {
        my @sub_fields = split(/\s+/, $check);
        my $ff_name = $sub_fields[$#sub_fields];
        if (exists $covered_ref->{$ff_name}) {
          #print "Removed $line\n";
          $remove_next = 1;
          next;
        }
      }
    }
    $cleaned .= $line . "\n";
  }
  return $cleaned;
}

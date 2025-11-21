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
  "q" => ["unsigned long", "v4ulong"],
  "l" => ["unsigned int", "v8uint"],
  "w" => ["unsigned short", "v16ushort"],
  "b" => ["unsigned char", "v32uchar"]
);
my %typeMap = (
  "v4ulong" => "LLVMVector4xi64",
  "v8uint" => "LLVMVector8xi32",
  "v16ushort" => "LLVMVector16xi16",
  "v32uchar" => "LLVMVector32xi8",
);
my $path = "$ARGV[0].helper_ymm";
`rm -rf $path`;
`mkdir -p $path`;
open FD, "< $ARGV[1]" or die "Cannot open $ARGV[1] for read!\n";
while (<FD>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /^<FunctionDefinition/) {
    my @fields = split(/\$\$/, $line);
    my $fullStart;
    my $fullStop;
    my $funcName;
    if ($#fields == 6) {
      my @f1 = split(/:/, $fields[1]);
      my @f2 = split(/:/, $fields[2]);
      my @f3 = split(/:/, $fields[3]);
      my @f4 = split(/:/, $fields[4]);
      my @f5 = split(/:/, $fields[5]);
      my @f6 = split(/:/, $fields[6]);
      $fullStart = $f5[1];
      $fullStop = $f4[1];
      $funcName = &GetText($f1[1], $f2[1], $ARGV[0]);
      $funcName =~ s/\r?\n//g;
    } elsif ($#fields == 5) {
      my @f1 = split(/:/, $fields[1]);
      my @f2 = split(/:/, $fields[2]);
      my @f3 = split(/:/, $fields[3]);
      my @f4 = split(/:/, $fields[4]);
      my @f5 = split(/:/, $fields[5]);
      $fullStart = $f1[1];
      $fullStop = $f4[1];
      $funcName = &GetText($f1[1], $f2[1], $ARGV[0]);
    } else {
      die "function definition info error!\n";
    }
    my $shortFuncName = "";
    if ($funcName =~ /^helper_([^\(\s]+)[\s\(]/) {
      $shortFuncName = $1;
    } elsif ($funcName =~ /\shelper_([^\(\s]+)[\s\(]/) {
      $shortFuncName = $1;
    }
    if ($shortFuncName ne "" and (not $shortFuncName =~ /^A_/) and ($shortFuncName =~ /_ymm$/)) {
      my $def = &GetText($fullStart, $fullStop, $ARGV[0]);
      $def = &UpdateFunc($def, $shortFuncName);
      if ($def ne "") {
        open OUT, "> $path/helper_${shortFuncName}.c" or die "cannot open $path/helper_${shortFuncName}.c for write!\n";
        print OUT "$def";
        close OUT;
      }
    }
  }
}
close FD;

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

sub UpdateFunc
{
  my ($funcStr, $funcShortName) = @_;
  $funcStr =~ s/_ymm\s*\(\s*ZMMReg/_ymm\(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip__EXTRACT_HELPER_CALL_PARAM__, ZMMReg/;
  $funcStr =~ s/_ymm\s*\(\s*CPUX86State\s*\*env\s*,\n?\s*/_ymm\(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip__EXTRACT_HELPER_CALL_PARAM__, /;
  my @fields = split("_ZMMReg", $funcStr);
  my $out = "";
  my %prefix = ();
  foreach my $i (0 .. ($#fields-1)) {
    if ($fields[$i] =~ /_([qlwb])$/) {
      my $p = $1;
      if (not exists $prefix{$p}) {
        $prefix{$p} = 0;
      }
      $prefix{$p} = $prefix{$p} + 1;
    }
  }
  my @sortedKeys = sort {$prefix{$a} <=> $prefix{$b}} keys %prefix;
  if (@sortedKeys == 0) {
    return "";
  }
  my $p = $sortedKeys[$#sortedKeys];
  my $entry = $prefixMap{$p};
  foreach my $k (keys %prefixMap) {
    $out = $out."typedef $prefixMap{$k}->[0] __attribute__((__vector_size__(32))) $prefixMap{$k}->[1];\n";
  }
  $out = $out."typedef unsigned long uintptr_t;\n";
  $out = $out."typedef unsigned long target_ulong;\n";
  $out = $out."typedef unsigned long uint64_t;\n";
  $out = $out."typedef long int64_t;\n";
  $out = $out."typedef unsigned int uint32_t;\n";
  $out = $out."typedef int int32_t;\n";
  $out = $out."typedef unsigned short uint16_t;\n";
  $out = $out."typedef short int16_t;\n";
  $out = $out."typedef unsigned char uint8_t;\n";
  $out = $out."typedef char int8_t;\n";
  $out = $out."#define helper_$funcShortName HELPER_NAME\n";
  $funcStr =~ s/,\sZMMReg\s\*/, $entry->[1] /g;
  $funcStr =~ s/\-\>_${p}_ZMMReg//g;
  if ($funcStr =~ /_ZMMReg/) {
    $funcStr = &ConvertType($funcStr, $p, $funcShortName);
    if ($funcStr eq "") {
      return "";
    }
  }

  # Do extract helper call parameters and setup macros, so that they can be replaced and inlined into AOT
  my @splits = split("__EXTRACT_HELPER_CALL_PARAM__,", $funcStr);
  if (@splits != 2) {
    die "BUG!\n";
  }
  my @sub_splits = split(/\)/, $splits[1]);
  my $arg_str = $sub_splits[0];
  $arg_str =~ s/\n//g;
  $arg_str =~ s/^\s*//;
  $arg_str =~ s/\s*$//;
  my @args = split(/,/, $arg_str);
  my $uniq_vec_type = "";
  my $additional_params = "";
  foreach my $i (0 .. $#args) {
    $args[$i] =~ s/^\s*//;
    $args[$i] =~ s/\s*$//;
    my @fields = split(/\s+/, $args[$i]);
    if (not exists $typeMap{$fields[0]}) {
        $additional_params = $additional_params.", $args[$i]";
        next;
    }
    if ($uniq_vec_type eq "") {
      $uniq_vec_type = $fields[0];
      print "vtype:$funcShortName:$typeMap{$uniq_vec_type}\n";
    } elsif ($uniq_vec_type ne $fields[0]) {
      die "BUG!\n";
    }
    $out = $out."#define $fields[1] ARGUMENT$i\n";
  }
  $funcStr = $splits[0].", YMM_PARAM_DECLARE$additional_params";
  foreach my $i (1 .. $#sub_splits) {
    $funcStr = $funcStr.")".$sub_splits[$i];
  }

  my $var = "";
  my $type = "";
  if ($funcStr =~ /return\s+(.*);/) {
    $var = $1;
    if ($funcStr =~ /([^\s]+)\s+helper_$funcShortName/) {
      $type = $1;
    } else {
      die "Return type not detected!\n";
    }
    if (not $funcStr =~ /$type\s+$var;/) {
      die "Type not verified!\n";
    }
    $funcStr =~ s/return\s+$var;//;
    $funcStr =~ s/$type\s+helper_$funcShortName/void helper_$funcShortName/;
  }
  
  # Add call to helper_A_return
  if ($var eq "") {
    $funcStr =~ s/}\s*$/return FUNC_RET(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip, YMM_PARAM_LIST);\n}/;
  } else {
    $funcStr =~ s/}\s*$/return FUNC_RET(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip, YMM_PARAM_LIST, $var);\n}/;
  }

  if ($var eq "") {
    $out = $out."extern __attribute__((qemuaot)) void FUNC_RET(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long cc_src, unsigned long cc_dst, unsigned int cc_op, unsigned long rip, YMM_PARAM_DECLARE_COMMON);\n";
  } else {
    $out = $out."extern __attribute__((qemuaot)) void FUNC_RET(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long cc_src, unsigned long cc_dst, unsigned int cc_op, unsigned long rip, YMM_PARAM_DECLARE_COMMON, $type $var);\n";
  }

  $out = $out."__attribute__((qemuaot,always_inline)) ";
  $out = $out.$funcStr;
  return $out;
}

sub ConvertType
{
  my ($funcStr, $defaultPrefix, $funcShortName) = @_;
  my $out = "";
  my %convertVars = ();
  my @fields = split("_ZMMReg", $funcStr);
  foreach my $i (0 .. ($#fields-1)) {
    if ($fields[$i] =~ /([a-zA-Z_][a-zA-Z_0-9]*)\-\>_([qlwb])$/) {
      my $var = $1;
      my $p = $2;
      if (not exists $convertVars{$var}) {
        my %info = ();
        $convertVars{$var} = \%info;
      }
      $convertVars{$var}->{$p} = 1;
    }
  }
  if (keys %convertVars == 0) {
    return "";
  }
  # Verify that if/while/for have surrounding braces, so that we can
  # arbitrarily expand statements without impact control flow.
  # Note this is preprocessed file, and comments are all removed already!
  # Ideally we need a parser to do the check!!!
  my $frags = &Split($funcStr, "if");
  if (@{$frags} > 1) {
    foreach my $i (1 .. $#{$frags}) {
      if (&GetFirstCharAfterBalancedParen($frags->[$i]) ne '{') {
        die "FIXME: to add Paren-if in $frags->[$i]\n$funcStr\n";
      }
    }
  }
  $frags = &Split($funcStr, "for");
  if (@{$frags} > 1) {
    foreach my $i (1 .. $#{$frags}) {
      if (&GetFirstCharAfterBalancedParen($frags->[$i]) ne '{') {
        die "FIXME: to add Paren-for in $frags->[$i]\n$funcStr\n";
      }
    }
  }
  $frags = &Split($funcStr, "while");
  if (@{$frags} > 1) {
    foreach my $i (1 .. $#{$frags}) {
      my $c = &GetFirstCharAfterBalancedParen($frags->[$i]);
      if ($c ne '{' and $c ne ';') {
        die "FIXME: to add Paren-while in $frags->[$i]\n$funcStr\n";
      }
    }
  }
  $frags = &Split($funcStr, "else");
  if (@{$frags} > 1) {
    foreach my $i (1 .. $#{$frags}) {
      my $c = &GetFirstChar($frags->[$i]);
      if ($c ne '{') {
        die "FIXME: to add Paren-else in $frags->[$i]\n$funcStr\n";
      }
    }
  }

  # Get the beginning of function, and do declare all necessary variables
  my @funcParts = split("{", $funcStr);
  if (@funcParts <= 1) {
    die "FIXME!\n";
  }
  $out = $funcParts[0]."{\n";
  foreach my $v (keys %convertVars) {
    foreach my $t (keys %{$convertVars{$v}}) {
      my $type = $prefixMap{$t}->[1];
      $out = $out."$type ${v}${t} = ($type)$v;\n";
    }
  }
  $out = $out.$funcParts[1];
  foreach my $i (2 .. $#funcParts) {
    $out = $out."{".$funcParts[$i];
  }
  # First round replace all RValues
  @fields = split("_ZMMReg", $out);
  $out = "";
  my $splitter = "";
  foreach my $i (0 .. ($#fields - 1)) {
    my $splitterNext = "_ZMMReg";
    if ($fields[$i] =~ /([a-zA-Z_][a-zA-Z_0-9]*)\-\>_([qlwb])$/) {
      my $var = $1;
      my $p = $2;
      my $operator = &GetFirstOperatorAfterBalancedBracket($fields[$i + 1]);
      $operator =~ s/\s//g;
      if ($operator eq "=") {
      } else {
        $fields[$i] =~ s/$var\-\>_${p}$/${var}${p}/;
        $splitterNext = "";
      }
    }
    $out = $out.$splitter.$fields[$i];
    $splitter = $splitterNext;
  }
  $out = $out.$splitter.$fields[$#fields];

  @fields = split("_ZMMReg", $out);
  $out = "";
  $splitter = "";
  foreach my $i (0 .. ($#fields - 1)) {
    my $splitterNext = "_ZMMReg";
    if ($fields[$i] =~ /([a-zA-Z_][a-zA-Z_0-9]*)\-\>_([qlwb])$/) {
      my $var = $1;
      my $p = $2;
      my $operator = &GetFirstOperatorAfterBalancedBracket($fields[$i + 1]);
      $operator =~ s/\s//g;
      if ($operator eq "=") {
        $fields[$i] =~ s/$var\-\>_${p}$/${var}${p}/;
        $fields[$i + 1] = &InsertUpdateForTypes($fields[$i + 1], $var, $defaultPrefix, $p, \%convertVars);
        $splitterNext = "";
      } else {
      }
    }
    $out = $out.$splitter.$fields[$i];
    $splitter = $splitterNext;
  }
  $out = $out.$splitter.$fields[$#fields];

  #print "Check $funcShortName\n";
  return $out;
}

sub InsertUpdateForTypes
{
  my ($input, $var, $defaultT, $newT, $cv) = @_;
  my @chars = split(//, $input);
  my $out = "";
  foreach my $i (0 .. $#chars) {
    my $c = $chars[$i];
    $out = $out.$c;
    if ($c eq ';') {
      $out = $out."\n"."$var = ($prefixMap{$defaultT}->[1])${var}${newT};\n";
      if (exists $cv->{$var}) {
        foreach my $k (keys %{$cv->{$var}}) {
          if ($k ne $newT) {
            $out = $out."${var}${k} = ($prefixMap{$k}->[1])$var;\n";
          }
        }
      }
      foreach my $j (($i + 1) .. $#chars) {
        $out = $out.$chars[$j];
      }
      last;
    }
  }
  return $out;
}

sub GetFirstOperatorAfterBalancedBracket
{
  my ($input) = @_;
  my @chars = split(//, $input);
  my $cnt = 0;
  my $capture = 0;
  my $on = 0;
  foreach my $i (0 .. $#chars) {
    my $c = $chars[$i];
    if ($c eq '[' and $on == 0) {
      $on = 1;
      $cnt = $cnt + 1;
    } elsif ($on == 1) {
      if ($c eq '[') {
        $cnt = $cnt + 1;
      } elsif ($c eq ']') {
        $cnt = $cnt - 1;
        if ($cnt == 0) {
          $on = 0;
          $capture = 1;
        }
      }
    } elsif ($capture == 1) {
      if (not $c =~ /\s/) {
        if (($i + 1) <= $#chars) {
          return "${c}$chars[$i+1]";
        } else {
          return "$c";
        }
      }
    }
  }
  return '!';
}

sub GetFirstCharAfterBalancedParen
{
  my ($input) = @_;
  my @chars = split(//, $input);
  foreach my $c (@chars) {
    if (not $c =~ /\s/) {
      if ($c ne '(') {
        return '{';
      } else {
        last;
      }
    }
  }
  my $cnt = 0;
  my $capture = 0;
  my $on = 0;
  foreach my $c (@chars) {
    if ($c eq '(' and $on == 0) {
      $on = 1;
      $cnt = $cnt + 1;
    } elsif ($on == 1) {
      if ($c eq '(') {
        $cnt = $cnt + 1;
      } elsif ($c eq ')') {
        $cnt = $cnt - 1;
        if ($cnt == 0) {
          $on = 0;
          $capture = 1;
        }
      }
    } elsif ($capture == 1) {
      if (not $c =~ /\s/) {
        return $c;
      }
    }
  }
  return '!';
}

sub GetFirstChar
{
  my ($input) = @_;
  my @chars = split(//, $input);
  foreach my $c (@chars) {
    if (not $c =~ /\s/) {
      return $c;
    }
  }
  return '!';
}

sub Split
{
  my ($input, $tag) = @_;
  my @arr = ();
  my @fields = split($tag, $input);
  my $last = $fields[0];
  foreach my $i (1 .. $#fields) {
    if ($last =~ /[a-zA-Z0-9_]$/ and $fields[$i] =~ /^[a-zA-Z0-9_]/) {
      $last = $last.$tag.$fields[$i];
    } else {
      push @arr, $last;
      $last = $fields[$i];
    }
  }
  push @arr, $last;
  return \@arr;
}

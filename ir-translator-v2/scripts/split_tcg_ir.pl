#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;

if ($#ARGV < 3) {
    print "Usage: ./script <tcg-ir> <with-dump-registers or not-:0> <with-instr-stats or not-:0> <ALL_EXTERNAL or output from collect_external_func_from_qemu_legacy_log.pl> <optional: [idx] to do function split>\n";
    exit 1;
}

my $script_file = basename($0);
my $script_folder = $0;
$script_folder =~ s/$script_file$//;
my $elf_address_range = 0x200000;

# Get ELF file info
my $elf_file = "";
my $last_elf = "";
my $argv0_path = `realpath $ARGV[0]`;
chomp($argv0_path);
my @fields = split(/\./, $argv0_path);
foreach my $f (@fields) {
  if ($elf_file eq "") {
    $elf_file = $f;
  } else {
    $elf_file = $elf_file.".".$f;
  }
  if (-e $elf_file) {
    my $file_info = `file $elf_file`;
    if ($file_info =~ /x86\-64/ and ($file_info =~ /executable/ or $file_info =~ /shared object/)) {
      $last_elf = $elf_file;
    }
  }
}
die "ELF file not identified!\n" if $last_elf eq "";

# Check if TCG IR comes from JIT, then we skip jump_table opt for now
my $is_jit_ir = 0;
open IN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
while (<IN>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /icount/) {
    if (not $line =~ /^\s*\$0x0:/) {
      $is_jit_ir = 1;
    }
    last;
  }
}
close IN;

# Tune job size
my $split_func_cnt = 400;
my $func_group_size_limit = 30;
my $func_split = -1;
if ($#ARGV >= 4) {
  $func_split = $ARGV[4];
}
my $restore_count_down = 0;
my $split_func_cnt_backup = $split_func_cnt;
my %func_group_size_stat = ();
my $current_func_group_cnt = 0;

# Get prefix name
my $prefix_name = $ARGV[0];
$prefix_name =~ s/\/$//;
@fields = split(/\//, $prefix_name);
$prefix_name = $fields[$#fields];
@fields = split(/[\._\-]/, $prefix_name);
$prefix_name = $fields[0];
if ($prefix_name =~ /\+/) {
  $prefix_name =~ s/\+/\\\+/g;
}
my %mandatory_external = ();
my %mandatory_internal = ();
my %force_group_together_raw = ();
my %conditional_external = ();
my $got_samples = 0;
my $all_external = 0;
if ($ARGV[3] eq "ALL_EXTERNAL") {
  $got_samples = 1;
  $all_external = 1;
} else {
  open IN, "< $ARGV[3]" or die "Cannot open $ARGV[3] for read!\n";
  while (<IN>) {
      my $line = $_;
      chomp($line);
      if ($line =~ /^${prefix_name}_func_([0-9a-f]+)/) {
          my $func = $1;
          $got_samples = 1;
          @fields = split(/\s+/, $line);
          if ($fields[1] eq "1") {
              $mandatory_external{$func} = 1;
          } elsif ($fields[1] eq "2") {
              $mandatory_internal{$func} = 1;
              my %small_group = ();
              $small_group{$func} = 1;
              my $least_func = $func;
              foreach my $idx (2 .. $#fields) {
                  $small_group{$fields[$idx]} = 1;
                  if (hex("0x".$fields[$idx]) < hex("0x".$least_func)) {
                      $least_func = $fields[$idx];
                  }
              }
              $force_group_together_raw{$least_func} = \%small_group;
          } else {
              my %src = ();
              foreach my $idx (2 .. $#fields) {
                  $src{$fields[$idx]} = 1;
              }
              $conditional_external{$func} = \%src;
          }
      }
  }
  close IN;
}

`rm -rf $ARGV[0].splits`;
if ($got_samples == 0) {
  print "Skip $ARGV[0]: qemu-legacy sample not found!\n";
  exit 0;
}
my $with_dump_registers = $ARGV[1];
my $with_instr_stats = $ARGV[2];
open IN, "< $ARGV[0]" or die "Cannot open $ARGV[0] for read!\n";
`mkdir -p $ARGV[0].splits`;
my @xmms = ();
my @funcs = ();
my @funcs_name = ();
my $current_func = "";
my $current_func_offset = "";
my $current_func_offset_raw = "";
# Why ignore the first half???
# During TCG IR generation, the first run does not have any idea if
# a particular instruction is jump destination, so we have to wait
# until the second turn for BB translation.
my $ignore_first_half = 2;
if ($is_jit_ir) {
  $ignore_first_half = 0;
}
my %offset_middle_to_front = ();
my $current_block_x86_offset = "";
while (<IN>) {
    my $line = $_;
    chomp($line);
    if ($line =~ /^\s*\$0x0:icount/) {
      $ignore_first_half = $ignore_first_half - 1;
    }
    if ((not $line =~ /^XMM/) and $ignore_first_half) {
      next;
    }
    if ($line =~ /Restarting code generation with smaller translation block/) {
      next;
    }
    if ($line =~ /^\s+\$(0x[0-9a-f]+):/) {
      $current_block_x86_offset = $1;
      if ($current_func_offset eq "") {
        $current_func_offset = $current_block_x86_offset;
        $current_func_offset_raw = $current_func_offset;
        $current_func_offset_raw =~ s/^0x//;
      } else {
        my $middle_offset = $current_block_x86_offset;
        $middle_offset =~ s/^0x//;
        $offset_middle_to_front{$middle_offset} = $current_func_offset_raw;
        next;
      }
    }
    if ($line =~ /^\s*exit_tb\s+/ or $line =~ /^\s*goto_ptr\s+/) {
      next;
    }
    if ($line =~ /call\s+lookup_tb_ptr,/) {
      $line = " call jmp_ind,\$0x1,\$0,rip";
    }
    if ($line =~ /^\s*ret\s+\$0x0$/) {
      $line = " ret rip";
    }
    if ($line =~ /^XMM/) {
        push @xmms, $line;
    } elsif ($line =~ /^$/) {
        if ($current_func ne "") {
            if (not $current_func =~ /^\s+\$(0x[0-9a-f]+):/) {
                die "BUG1:\n$current_func!\n";
            }
            $current_func =~ s/^\s+//;
            push @funcs, $current_func;
            push @funcs_name, $current_func_offset_raw;
            $current_func = "";
            $current_func_offset = "";
            $current_func_offset_raw = "";
        }
    } else {
        $current_func = $current_func.$line."\n";
    }
}
close IN;
my %force_group_together = ();
foreach my $k (keys %force_group_together_raw) {
    my $nk = $k;
    if (exists $offset_middle_to_front{$k}) {
        $nk = $offset_middle_to_front{$k};
    }
    my %elem = ();
    foreach my $sub_k (keys %{$force_group_together_raw{$k}}) {
        if (exists $offset_middle_to_front{$sub_k}) {
            $elem{$offset_middle_to_front{$sub_k}} = 1;
        } else {
            $elem{$sub_k} = 1;
        }
    }
    $force_group_together{$nk} = \%elem;
}
if ($current_func ne "") {
    if (not $current_func =~ /^\s+\$0x[0-9a-f]+:/) {
        die "BUG2!\n";
    }
    $current_func =~ s/^\s+//;
    push @funcs, $current_func;
    die "" if $current_func_offset_raw eq "";
    push @funcs_name, $current_func_offset_raw;
}
my $idx = 0;
my $file_idx = 0;
my $cnt_in_current_ir = 0;
if ($func_split == $file_idx) {
    $restore_count_down = $split_func_cnt;
    $split_func_cnt = 1;
}
open OUT, "> $ARGV[0].splits/$file_idx.tcg.ir" or die "Cannot open $ARGV[0].splits/$file_idx.tcg.ir for write!\n";
my $last_file_idx = $file_idx;
$file_idx = $file_idx + 1;
foreach my $x (@xmms) {
    print OUT "$x\n";
}
print OUT "\n";
my @all_external_ret = ();
my %buffered_funcs = ();
my @out_buffer = ();
my %current_force_group = ();
while ($idx < @funcs) {
    if ($cnt_in_current_ir >= $split_func_cnt and keys %current_force_group == 0) {
        if ($split_func_cnt == 1) {
            if ($restore_count_down == 0) {
                $split_func_cnt = $split_func_cnt_backup;
            } else {
                $restore_count_down = $restore_count_down - 1;
            }
        }
        # We should start an IR file with EXTERNAL function
        if ($all_external or exists $mandatory_external{$funcs_name[$idx]}) {
            foreach my $in (@out_buffer) {
                if ($all_external or exists $mandatory_external{$in->{'FUNC'}}) {
                    print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
                } elsif (exists $mandatory_internal{$in->{'FUNC'}}) {
                    print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
                } elsif (exists $conditional_external{$in->{'FUNC'}}) {
                    foreach my $k (keys %{$conditional_external{$in->{'FUNC'}}}) {
                        if (exists $buffered_funcs{$k}) {
                            delete $conditional_external{$in->{'FUNC'}}->{$k};
                        }
                    }
                    if (keys %{$conditional_external{$in->{'FUNC'}}} == 0) {
                        if ($current_func_group_cnt >= $func_group_size_limit) {
                            print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
                        } else {
                            print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
                        }
                    } else {
                        print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
                    }
                } else {
                    if ($current_func_group_cnt >= $func_group_size_limit) {
                        print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
                    } else {
                        print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
                    }
                }
            }
            close OUT;
            %buffered_funcs = ();
            @out_buffer = ();
            if ($func_split == $file_idx) {
                $restore_count_down = $split_func_cnt;
                $split_func_cnt = 1;
            }
            open OUT, "> $ARGV[0].splits/$file_idx.tcg.ir" or die "Cannot open $ARGV[0].splits/$file_idx.tcg.ir for write!\n";
            $last_file_idx = $file_idx;
            $file_idx = $file_idx + 1;
            foreach my $x (@xmms) {
                print OUT "$x\n";
            }
            print OUT "\n";
            $cnt_in_current_ir = 0;
        }
    }
    my %buf_info = ();
    $buf_info{'OUT'} = $funcs[$idx];
    $buf_info{'FUNC'} = $funcs_name[$idx];
    if (exists $force_group_together{$funcs_name[$idx]}) {
        foreach my $ef (keys %{$force_group_together{$funcs_name[$idx]}}) {
            $current_force_group{$ef} = 1;
        }
    }
    if (exists $current_force_group{$funcs_name[$idx]}) {
        delete $current_force_group{$funcs_name[$idx]};
    }
    if ($is_jit_ir == 0 and $all_external and $buf_info{'OUT'} =~ /\sret\s/) {
        push @all_external_ret, \%buf_info;
    } else {
        push @out_buffer, \%buf_info;
        $cnt_in_current_ir = $cnt_in_current_ir + 1;
    }
    $buffered_funcs{$funcs_name[$idx]} = 1;
    $idx = $idx + 1;
    my $info_ptr = \%buf_info;
    while ($all_external and $info_ptr->{'OUT'} =~ /\spush_ret_addr\s/) {
        my %buf_info2 = ();
        $buf_info2{'OUT'} = $funcs[$idx];
        $buf_info2{'FUNC'} = $funcs_name[$idx];
        if ($is_jit_ir == 0 and $all_external and $buf_info2{'OUT'} =~ /\sret\s/) {
          push @all_external_ret, \%buf_info2;
        } else {
          push @out_buffer, \%buf_info2;
          $cnt_in_current_ir = $cnt_in_current_ir + 1;
        }
        $buffered_funcs{$funcs_name[$idx]} = 1;
        $idx = $idx + 1;
        $info_ptr = \%buf_info2;
    }
}
if (@out_buffer) {
    foreach my $in (@out_buffer) {
        if ($all_external or exists $mandatory_external{$in->{'FUNC'}}) {
            print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
        } elsif (exists $mandatory_internal{$in->{'FUNC'}}) {
            print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
        } elsif (exists $conditional_external{$in->{'FUNC'}}) {
            foreach my $k (keys %{$conditional_external{$in->{'FUNC'}}}) {
                if (exists $buffered_funcs{$k}) {
                    delete $conditional_external{$in->{'FUNC'}}->{$k};
                }
            }
            if (keys %{$conditional_external{$in->{'FUNC'}}} == 0) {
                if ($current_func_group_cnt >= $func_group_size_limit) {
                    print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
                } else {
                    print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
                }
            } else {
                print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
            }
        } else {
            if ($current_func_group_cnt >= $func_group_size_limit) {
                print OUT &add_dump_stats("EXTERNAL:$in->{'OUT'}\n");
            } else {
                print OUT &add_dump_stats("INTERNAL:$in->{'OUT'}\n");
            }
        }
    }
    close OUT;
} else {
    close OUT;
    $file_idx = $file_idx - 1;
    `rm -f $ARGV[0].splits/$file_idx.tcg.ir`;
}

my $ret_idx = 0;
while ($all_external and @all_external_ret > 0) {
  open OUT, "> $ARGV[0].splits/RET$ret_idx.tcg.ir" or die "Cannot open $ARGV[0].splits/RET$ret_idx.tcg.ir for write!\n";
  $last_file_idx = $ret_idx;
  foreach my $x (@xmms) {
      print OUT "$x\n";
  }
  print OUT "\n";
  my $count = 400;
  while ($count > 0 and @all_external_ret) {
      my $entry = shift @all_external_ret;
      print OUT &add_dump_stats("EXTERNAL:$entry->{'OUT'}\n");
      $count = $count - 1;
  }
  close OUT;
  $ret_idx = $ret_idx + 1;
}
`ls $ARGV[0].splits/*.ir | parallel $script_folder/update_alignment.pl`;
`ls $ARGV[0].splits/*.ir | parallel $script_folder/update_unaligned_scalar_memory.pl`;
open OUT, "> $ARGV[0].splits/END.hex" or die "Cannot open $ARGV[0].splits/END.hex for write!\n";
print OUT "$current_block_x86_offset\n";
close OUT;

print "$ARGV[0] func group size stat:\nsize count\n";
my @sorted_key = sort {$a <=> $b} keys %func_group_size_stat;
foreach my $k (@sorted_key) {
    print "$k $func_group_size_stat{$k}\n";
}

sub add_dump_stats
{
    my ($input) = @_;
    my $type;
    my $current_func_offset;
    my $icount;

    if ($input =~ /^EXTERNAL/) {
        if ($current_func_group_cnt > 0) {
            if (not exists $func_group_size_stat{$current_func_group_cnt}) {
                $func_group_size_stat{$current_func_group_cnt} = 0;
            }
            $func_group_size_stat{$current_func_group_cnt} = $func_group_size_stat{$current_func_group_cnt} + 1;
            $current_func_group_cnt = 0;
        }
    }
    $current_func_group_cnt = $current_func_group_cnt + 1;
    if ($input =~ /^(INTERNAL|EXTERNAL):\$0x([0-9a-f]+):icount:([0-9]+):/) {
        $type = $1;
        $current_func_offset = $2;
        $icount = $3;
    } else {
        die "";
    }
    my $icount_hex = sprintf("0x%x", $icount);
    my $add_for_stats = "";
    if ($with_instr_stats) {
        $add_for_stats = " add_i64 loc641,env,\$0x0\n";
        $add_for_stats = $add_for_stats." sub_i64 loc641,loc641,\$0x30\n";
        $add_for_stats = $add_for_stats." qemu_ld_i64 loc642,loc641,noat+al8+leq,2\n";
        $add_for_stats = $add_for_stats." add_i64 loc642,loc642,\$$icount_hex\n";
        $add_for_stats = $add_for_stats." qemu_st_i64 loc642,loc641,noat+al8+leq,2\n";
        if (hex("0x".$current_func_offset) < $elf_address_range) {
            $add_for_stats = $add_for_stats." add_i64 loc644,env,\$0x0\n";
            $add_for_stats = $add_for_stats." sub_i64 loc644,loc644,\$0x28\n";
            $add_for_stats = $add_for_stats." qemu_ld_i64 loc645,loc644,noat+al8+leq,2\n";
            my $pointer_hex_offset = sprintf("0x%x", hex("0x".$current_func_offset)*8);
            $add_for_stats = $add_for_stats." add_i64 loc645,loc645,\$$pointer_hex_offset\n";
            $add_for_stats = $add_for_stats." qemu_ld_i64 loc646,loc645,noat+al8+leq,2\n";
            $add_for_stats = $add_for_stats." add_i64 loc646,loc646,\$0x1\n";
            $add_for_stats = $add_for_stats." qemu_st_i64 loc646,loc645,noat+al8+leq,2\n";
        }
    }
    if ($with_dump_registers) {
        $input =~ s/^$type:\$0x$current_func_offset:icount:$icount:\n/$type:\$0x$current_func_offset:\ncall dump_registers,\$0x0,\$0,env,\$0x$current_func_offset\n$add_for_stats/;
    } else {
        $input =~ s/^$type:\$0x$current_func_offset:icount:$icount:\n/$type:\$0x$current_func_offset:\n$add_for_stats/;
    }
    return $input;
}

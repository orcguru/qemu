#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use File::Basename;
use Cwd 'abs_path';
use Math::BigInt;
use JSON;

if ($#ARGV < 0) {
  print "Usage: ./script <tcg-ir-splits folder> <output AOT name>\n";
  exit 1;
}
my $script_file = basename($0);
my $script_folder = `realpath $0`;
chomp($script_folder);
$script_folder =~ s/$script_file$//;

my $obj_folder = `realpath $ARGV[0]`;
chomp($obj_folder);
my $output_aot_name = "";
if ($#ARGV > 0) {
  $output_aot_name = $ARGV[1];
}
my $arch = `uname -m`;
chomp($arch);
# Get ELF file info
my $elf_file = "";
my $last_elf = "example";
my @fields = split(/\./, $obj_folder);
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

# Do relink to sort function orders
my $dh;
opendir($dh, $obj_folder) or die "Cannot open directory: $!";
open OUT1, "> $obj_folder/cmd1" or die "Cannot open $obj_folder/cmd1 for write!\n";
open OUT2, "> $obj_folder/cmd2" or die "Cannot open $obj_folder/cmd2 for write!\n";
open OUT3, "> $obj_folder/cmd3" or die "Cannot open $obj_folder/cmd3 for write!\n";
while (my $file = readdir($dh)) {
  next if $file =~ /^\.\.?$/;
  if (not $file =~ /\.o$/) {
    next;
  }
  # Generate custom linker script for each file
  my $linker_script = "$obj_folder/$file.custom.ld";
  my $entry_info = "$obj_folder/$file.custom.ld.entry";
  my $obj_file = "$obj_folder/$file";
  open OUT, "> $linker_script" or die "Cannot open $linker_script for write!\n";
  open ENTRY, "> $entry_info" or die "Cannot open $entry_info for write!\n";
  print OUT "SECTIONS {\n";
  print OUT "  .text : {\n";
  print OUT "    *(.text)\n";
  my @func_list = split(/\n/, `objdump -t $obj_file | grep -w g | grep ".text.Fx" | awk '{print \$NF}'`);
  my %hex_prefix = ();
  foreach my $f (@func_list) {
    my $f_name = $f;
    $f =~ s/^Fx/0x/;
    my $postidx = 0;
    if ($f =~ /_/) {
      my @sub_fields = split(/_/, $f);
      $f = $sub_fields[0];
      $postidx = $sub_fields[1];
    }
    my $hex_val = hex($f);
    if (not exists $hex_prefix{$hex_val}) {
      my %info = ();
      $hex_prefix{$hex_val} = \%info;
    }
    $hex_prefix{$hex_val}->{$postidx} = $f_name;
  }
  my $emit_entry_done = 0;
  foreach my $k1 (sort {$a <=> $b} keys %hex_prefix) {
    foreach my $k2 (sort {$a <=> $b} keys %{$hex_prefix{$k1}}) {
      print OUT "    *(.text.$hex_prefix{$k1}->{$k2})\n";
      if ($emit_entry_done == 0) {
        $emit_entry_done = 1;
        print ENTRY "ENTRY($hex_prefix{$k1}->{$k2})\n";
      }
    }
  }
  print OUT "  }\n";
  print OUT <<EOF;
    .text.trampoline : { *(.text.trampoline) }
    .text.helper : { *(.text.helper) }
    .text.declare_only : { *(.text.declare_only) }
    .rodata : { *(.rodata) }
    .bss : { *(.bss) }
    .comment : { *(.comment) }
    .note.GNU-stack : { *(.note.GNU-stack) }
  }
EOF
  close OUT;
  close ENTRY;
  print OUT1 "ld --no-eh-frame-hdr -r -o $obj_file.relink -T $linker_script $obj_file\n";
  if ($arch eq "riscv64") {
    print OUT2 "/usr/bin/llvm-objcopy --remove-section=.comment --remove-section=.riscv.attributes $obj_file.relink $obj_file\n";
  } else {
    print OUT2 "/usr/bin/llvm-objcopy --remove-section=.comment $obj_file.relink $obj_file\n";
  }
  print OUT3 "rm $obj_file.relink\n";
}
closedir($dh);
close OUT1;
close OUT2;
close OUT3;
`cat $obj_folder/cmd1 | parallel`;
`sync`;
`cat $obj_folder/cmd2 | parallel`;
`sync`;
`cat $obj_folder/cmd3 | parallel`;

# Do final link
my $total_obj_order = "";
my %obj_name = ();
opendir($dh, $obj_folder) or die "Cannot open directory: $!";
while (my $file = readdir($dh)) {
  next if $file =~ /^\.\.?$/;
  if (not $file =~ /\.ir$/) {
    next;
  }
  if ($file =~ /^([0-9]+).tcg.ir/) {
    my $num = $1;
    $obj_name{$num} = 1;
  }
}
my $entry_name = "";
closedir($dh);
if (keys %obj_name > 0) {
  my @sorted_obj_name = sort {$a <=> $b} keys %obj_name;
  foreach my $e (@sorted_obj_name) {
    $total_obj_order = $total_obj_order." $e.tcg.ir.o";
  }
  $entry_name = $sorted_obj_name[0].".tcg.ir.o.custom.ld.entry";
} else {
  opendir($dh, $obj_folder) or die "Cannot open directory: $!";
  while (my $file = readdir($dh)) {
    next if $file =~ /^\.\.?$/;
    if (not $file =~ /\.o$/) {
      next;
    }
    if ($entry_name eq "") {
      $entry_name = "$file.custom.ld.entry";
    }
    $total_obj_order = $total_obj_order." $obj_folder/$file";
  }
  closedir($dh);
}
if ($output_aot_name eq "") {
  @fields = split(/\//, $last_elf);
  my $last_elf_name = $fields[$#fields];
  $output_aot_name = "$last_elf_name.aot.pre";
}
`rm -f $obj_folder/custom.ld`;
`cp $obj_folder/$entry_name $obj_folder/custom.ld`;
`cat $script_folder/custom_fixed_pie.ld >> $obj_folder/custom.ld`;
if ($arch eq "aarch64") {
  `cd $obj_folder && ld --allow-multiple-definition --no-eh-frame-hdr -T custom.ld -pie -o $output_aot_name $total_obj_order $script_folder/../tools/libhelper.so /lib64/libc.so.6 /lib/ld-linux-aarch64.so.1`;
} else {
  `cd $obj_folder && ld --allow-multiple-definition --no-eh-frame-hdr -T custom.ld -pie -o $output_aot_name.raw $total_obj_order $script_folder/../tools/libhelper.so /lib/riscv64-linux-gnu/libc.so.6 /lib/ld-linux-riscv64-lp64d.so.1`;
  `cd $obj_folder && /usr/bin/llvm-objcopy --remove-section=.riscv.attributes $output_aot_name.raw $output_aot_name`;
  `cd $obj_folder && rm -f $output_aot_name.raw`;
}
print "Finished $obj_folder\n";
select()->flush();

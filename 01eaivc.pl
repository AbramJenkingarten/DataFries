#!/usr/bin/perl -w
# input format
# time price volume dir
# output format
# time meanPrice maxPrice minPrice sumVol count
use strict;

#my $srcdir = "/venv/data/Si14X";
#my $srcdir = "/venv/data/Si153";
#my $srcdir = "/venv/data/Si156";
#my $srcdir = "/venv/data/Si159";
#my $srcdir = "/venv/data/Si15X";
#my $srcdir = "/venv/data/Si163";
#my $srcdir = "/venv/data/Si166";
#my $srcdir = "/venv/data/Si169";
#my $srcdir = "/venv/data/Si16X";
#my $srcdir = "/venv/data/Si173";
#my $srcdir = "/venv/data/Si176";
#my $srcdir = "/venv/data/Si179";
#my $srcdir = "/venv/data/Si17X";
#my $srcdir = "/venv/data/Si183";
#my $srcdir = "/venv/data/Si186";
#my $srcdir = "/venv/data/Si189";
#my $srcdir = "/venv/data/Si18X";
#my $srcdir = "/venv/data/Si193";
#my $srcdir = "/venv/data/Si196";
#my $srcdir = "/venv/data/Si199";
#my $srcdir = "/venv/data/Si19X";
#my $srcdir = "/venv/data/Si203";

my $srcdir =  "/venv/data/Si206";
my $dstdir = "/venv/data2/Si206";

system("ls -1 $srcdir |sort >./ls1");
open(FHLS,"./ls1");

my $file;

open(Fcmd,">>./Fcmd");
print Fcmd "create table trades(\"time\" integer, \"price\" integer, \"vol\" integer, \"dir\" text); \n";
print Fcmd ".mode csv \n";
print Fcmd ".separator ; \n";


while(defined($file=<FHLS>))
    {
    chomp($file);
    print Fcmd ".import $srcdir/$file trades \n";

    print Fcmd ".output $dstdir/a-$file \n";
    print Fcmd "select time,round(sum(price)/count(*)),max(price),min(price),sum(vol),count(*) from trades where time between 300 and 14400 group by time order by time; \n";
    print Fcmd ".output $dstdir/b-$file \n";
    print Fcmd "select time,round(sum(price)/count(*)),max(price),min(price),sum(vol),count(*) from trades where time between 14700 and 31500 group by time order by time; \n";
    print Fcmd ".output $dstdir/c-$file \n";
    print Fcmd "select time,round(sum(price)/count(*)),max(price),min(price),sum(vol),count(*) from trades where time between 32400 and 49800 group by time order by time; \n";

    print Fcmd "delete from trades; \n";
    }

print Fcmd ".exit \n";
close Fcmd;

close(FHLS);
system("rm ./ls1");
system("cat ./Fcmd | sqlite3");
system("rm ./Fcmd");

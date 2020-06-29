#!/usr/bin/perl -w

# format
# 0Received;1ExchTime;2OrderId;3Price;4Amount;5AmountRest;6DealId;7DealPrice;8OI;9Flags
# 21.06.2018 10:28:05.294;21.06.2018 10:28:34.751;31251204973;64436;1;0;2061560913;64436;1444866;Fill, Sell, FillOrKill
# 21.06.2018 10:28:05.294;21.06.2018 10:28:34.751;31251204957;64436;1;4;2061560913;64436;1444866;Fill, Buy, Quote, EndOfTransaction
# Здесь две заявки сведены в сделку
# Сначала приходит котировочная заявка (Quote), у нее меньше OrderId
# Об котировочную заявку частично или полностью закрываются встречная заявка (Counter) или заявки полного исполнения (FillOrKill).
# А DealId у котировочной и встречной должны быть одинаковы.
# Price - это цена размещенной заявки, DealPrice - это цена по которой заявка исполнена
use strict;

my $srcdir = "/venv/data/QSH.Si-12.19";
my $dstdir = "/venv/data/Si19X";

my $str ="";
my $file="";

system("ls -1 $srcdir |sort >./ls1");
open(FHLS,"./ls1");

while(defined($file=<FHLS>))
  {
  chomp($file);
  my @f2=split(/\./,$file);
  print "$file => $f2[2].$f2[5]\n";
  system("grep Fill $srcdir/$file | grep -v NonSystem >/tmp/fltr");

  open(FHI,"/tmp/fltr");
  open(FHO,">$dstdir/$f2[2].$f2[5]");
  print FHO "time,deal,order,price,volume,dir\n";
  while(defined($str=<FHI>))
    {
    my @a=split(/;/,$str);
    # if DealId is 0
    if($a[6]==0){next;}
    # DealId is negative ten digits.  Оставляем изменяемые цифры + еще одну, т.е. 8
    my $DealId = substr($a[6],-8);
    # OrderId is eleven digits. Оставляем изменяемые цифры + еще одну, т.е. 9
    my $OrderId = substr($a[2],-9);
    
    # Select time from ExchTime.
    my @t1=split(/ /,$a[1]);
    my @t2=split(/\./,$t1[1]);
    my @t3=split(/\:/,$t2[0]);
    my $t4=$t3[0]*60*60+$t3[1]*60+$t3[2]-36000;
    my @flags=split(/\,/,$a[9]);
    my $dir;
    if($flags[1] eq " Sell")
      {$dir="s";}
    else
      {$dir="b";}

    # Время 6DealId 2OrderId 7DealPrice 4Amount 9Flags
    print FHO "$t4\t$DealId\t$OrderId\t$a[7]\t$a[4]\t$dir\n";
    }
#  print "grep $str $srcdir/$file >>$dstdir/$a[2].$a[5]\n";
#  system("grep $str $srcdir/$file >>$dstdir/$a[2].$a[5]");
  }

close(FHLS);
system("rm ./ls1");



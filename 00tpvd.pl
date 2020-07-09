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

my $srcdir = "/venv/data/Si-6.20";
my $dstdir = "/venv/data/Si206";

my $str ="";
my $file="";

system("ls -1 $srcdir |sort >./ls1");
open(FHLS,"./ls1");

while(defined($file=<FHLS>))
  {
  chomp($file);
  my @f2=split(/\./,$file);
  print "$file => $f2[2].$f2[5]\n";
  ### Первый фильтр: оставляем сделки и убираем несистемные сделки
  system("grep Fill $srcdir/$file | grep -v NonSystem >/tmp/fltr1");

  open(FHI,"/tmp/fltr1");
  open(FHO,">/tmp/fltr2");
  #print FHO "time,deal,order,price,volume,dir\n";
  while(defined($str=<FHI>))
    {
    my @a=split(/;/,$str);
    # Фильтр сделок: если поле DealId равно 0, то отбрасываем строку
    if($a[6]==0){next;}

    # Фильтр дат: Received и ExchTime должны быть в один день
    my @d0=split(/ /,$a[0]);
    my @d1=split(/ /,$a[1]);
    if ($d0[0] ne $d1[0]){next;}

    # Конвертируем время
    my @t1=split(/ /,$a[1]);
    my @t2=split(/\./,$t1[1]);
    my @t3=split(/\:/,$t2[0]);
    my $t4=$t3[0]*60*60+$t3[1]*60+$t3[2]-36000;

    # Из флагов выбираем направление сделки
    my @flags=split(/\,/,$a[9]);
    my $dir;
    if($flags[1] eq " Sell")
      {$dir="s";}
    if($flags[1] eq " Buy")
      {$dir="b";}

    # Время 6DealId 2OrderId 7DealPrice 4Amount 9Flags
    print FHO "$t4;$a[6];$a[2];$a[7];$a[4];$dir\n";
    }
  close(FHI);
  close(FHO);

  #
  open(FHI,"/tmp/fltr2");
  open(FHO,">$dstdir/$f2[2].$f2[5]");

  my $str1=<FHI>;
  my $str2="";
  my $dir="";
  while(defined($str2=<FHI>))
    {
    chomp($str1); chomp($str2);
    my @a1=split(/;/,$str1);
    my @a2=split(/;/,$str2);
    if($a1[1] != $a2[1])
        {$str1=$str2;next;}
    if($a1[2] < $a2[2])
        {print FHO "$a2[0];$a2[3];$a2[4];$a2[5]\n";}
    else
        {print FHO "$a1[0];$a1[3];$a1[4];$a1[5]\n";}
    }

  close(FHI);
  close(FHO);
  system("rm /tmp/fltr1");
  system("rm /tmp/fltr2");
  }

close(FHLS);
system("rm ./ls1");

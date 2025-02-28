#!/usr/local/bin/perl

($infile,$Navr,$outfile) = @ARGV;

open(IN,$infile);
<IN>;

$jk=-1;
while($row=<IN>){
    $jk++;
    @cols=split(' ',$row);
    for ($kt=0;$kt<=$#cols;$kt++){
	$savecols{$jk,$kt} = $cols[$kt];
    }
}
close(IN);
$Ndata = $jk+1;

print "Number of columns = ",($#cols+1),"\n";
print "Number of rows    = ",$Ndata,"\n";

for ($nf=0;$nf<($Navr-1);$nf++){
    for ($kt=0;$kt<=$#cols;$kt++){
	$Sum[$kt] += $savecols{$nf,$kt};
    }
}

open(OUT,"> $outfile");
for ($nf=$Navr-1;$nf<$Ndata;$nf++){
    for ($kt=0;$kt<=$#cols;$kt++){
	$Sum[$kt] += $savecols{$nf,$kt};
	print OUT "  ",($Sum[$kt]/$Navr);
    }
    print OUT "\n";
    for ($kt=0;$kt<=$#cols;$kt++){
	$Sum[$kt] -= $savecols{($nf-$Navr+1),$kt};
    }
}
close(OUT);

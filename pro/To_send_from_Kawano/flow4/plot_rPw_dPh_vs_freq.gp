FINNAME  = ARG1
FOUTNAME = ARG2
XaxMin   = ARG3
XaxMax   = ARG4


print "FINNAME =  ", FINNAME
print "FOUTNAME = ", FOUTNAME


set term pngcairo monochrome
set output
set output FOUTNAME

set multiplot layout 2,1
set xrange [XaxMin:XaxMax]

# set lmargin 10
set logscale y

set xlabel 'frequency [mHz]'
set ylabel 'Power Ratio'
set format x "%1.0f"
set format y "%4.0f"
plot FINNAME u ($1*1000):2 notitle w lp 

unset logscale y
set xlabel 'frequency [mHz]'
set ylabel 'Phase Diff. [deg]'
set format y "%4.0f"
plot FINNAME u ($1*1000):3 notitle w lp 

unset multiplot
exit gnuplot

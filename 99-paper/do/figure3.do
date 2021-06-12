use "$final_data", clear

// Create a f3 folder to store outputs if it doesn't exist 
capture mkdir "figures/f3/"

twoway kdensity difference_dap if treatment==0, lcolor(red) range(-250 500) fcolor(red%50) recast(area) || ///
kdensity difference_dap if treatment==1, range(-250 500) xscale(range(-250 500)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: DAP") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f3/dap.png")


twoway kdensity difference_urea if treatment==0, lcolor(red) range(-750 450) fcolor(red%50) recast(area) || ///
kdensity difference_urea if treatment==1, range(-750 450) xscale(range(-750 450)) xline(0, lcolor(black)) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: UREA") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f3/urea.png")


twoway kdensity difference_mop if treatment==0, lcolor(red) range(-375 125) fcolor(red%50) recast(area) || ///
kdensity difference_mop if treatment==1, range(-375 125) xscale(range(-375 125)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: MOP") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f3/mop.png")


twoway kdensity difference_zinc if treatment==0, lcolor(red) range(-32 32) fcolor(red%50) recast(area) || ///
kdensity difference_zinc if treatment==1, range(-32 32) xscale(range(-32 32)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: Zinc") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f3/zinc.png")

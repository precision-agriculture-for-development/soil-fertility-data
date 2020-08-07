use "$final_data", clear

// Create a f2 folder to store outputs if it doesn't exist 
capture confirm file "figures/f2/"
if _rc mkdir "figures/f2/"


twoway kdensity difference_DAP if treatment==0, lcolor(red) range(-125 500) fcolor(red%50) recast(area) || ///
kdensity difference_DAP if treatment==1, range(-125 500) xscale(range(-125 500)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: DAP") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f2/DAP.png")


twoway kdensity difference_UREA if treatment==0, lcolor(red) range(-190 125) fcolor(red%50) recast(area) || ///
kdensity difference_UREA if treatment==1, range(-190 125) xscale(range(-190 125)) xline(0, lcolor(black)) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: UREA") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f2/UREA.png")


twoway kdensity difference_MOP if treatment==0, lcolor(red) range(-375 65) fcolor(red%50) recast(area) || ///
kdensity difference_MOP if treatment==1, range(-375 65) xscale(range(-375 65)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: MOP") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f2/MOP.png")


twoway kdensity difference_ZINC if treatment==0, lcolor(red) range(-32 7) fcolor(red%50) recast(area) || ///
kdensity difference_ZINC if treatment==1, range(-32 7) xscale(range(-32 7)) xline(0, lcolor(black)) lcolor(blue) fcolor(blue%50) recast(area) ///
ytitle("Density") xtitle("Difference between used and recommended fertilizer: Zinc") ///
plotregion(margin(b = 0)) ///
legend(order(1 2) region(lwidth(none)) label(1 "Control") label(2 "Treatment") ///
place(1) /// 
bmargin(small) bplacement(1)  rows(2) ring(0) symysize(tiny) symxsize(small) size(small) ) ///
graphregion(color(white)) xlabel(, format(%12.0fc))

gexport, file("figures/f2/ZINC.png")


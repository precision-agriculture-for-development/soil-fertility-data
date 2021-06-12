use "$final_data", clear

// Create a f6 folder to store outputs if it doesn't exist 
capture mkdir "figures/f6/"


set scheme plotplain

scatter yield_hectare_2018 max_ndvi_2018, xtitle("NDVI")
gexport, file("figures/f6/NDVI.png")

scatter yield_hectare_2018 max_gcvi_2018, xtitle("GCVI")
gexport, file("figures/f6/GCVI.png")

scatter yield_hectare_2018 max_re705_2018, xtitle("reNDVI")
gexport, file("figures/f6/reNDVI.png")

scatter yield_hectare_2018 max_mtci_2018, xtitle("MTCI")
gexport, file("figures/f6/MTCI.png")

scatter yield_hectare_2018 max_lai_2018, xtitle("LAI")
gexport, file("figures/f6/LAI.png")

drop _all
set more off
version 16

cd "INSERT_MAIN_PATH/05-satellite-yield-measurements"

tempfile master

import delimited using "03-intermediate-data/Endline/area.csv", clear

duplicates drop id, force //there's a single true duplicate 

local files : dir "03-intermediate-data/Endline/" files "*.csv"
foreach file in `files' {

  if "`file'" == "area.csv" {
  // Pass
  }
  else if strpos("`file'", "color") {
  	// Pass - true color and false color composites 
  }
  else {
    save `master', replace 

    import delimited using "03-intermediate-data//`file'", clear

    duplicates drop id, force 

    local root = substr("`file'",1,length("`file'")-4)
    
    foreach var of varlist mean median {
      local newvarname = "`root'_`var'"
      rename `var' `newvarname' 
    }

    merge 1:1 id using `master', assert(3) nogenerate

    }
  }
  
//Add the placebo data 
local files : dir "03-intermediate-data/placebo/" files "*.csv"
foreach file in `files' {
if strpos("`file'", "grid_fe") {
    save `master', replace 

    import delimited using "03-intermediate-data/placebo/`file'", clear

    duplicates drop uid, force 
    rename uid id

    merge 1:1 id using `master', assert(3) nogenerate
     }

	
else if strpos("`file'", "color") {
  	// Pass - true color and false color composites 
     }
else {

    save `master', replace 

    import delimited using "03-intermediate-data/placebo/`file'", clear

    duplicates drop id, force 

    local root = substr("`file'",1,length("`file'")-4)
    
    foreach var of varlist mean median {
      local newvarname = "placebo_`root'_`var'"
      rename `var' `newvarname' 
    }

    merge 1:1 id using `master', assert(3) nogenerate

    }
}

//Next merge Planet data
local files : dir "03-intermediate-data/Endline-Planet/" files "*.csv"
foreach file in `files' {

  save `master', replace 

  import delimited using "03-intermediate-data/Endline-Planet/`file'", clear

  duplicates drop id, force 

  local root = substr("`file'",1,length("`file'")-4)

  foreach var of varlist mean median {
    local newvarname = "`root'_`var'"
    rename `var' `newvarname' 
  }

  merge 1:1 id using `master', assert(3) nogenerate

}

//Next merge in rainfall data -- this was originally using downloaded geotiffs, but this now switches to Google Earth Engine Data

preserve 

import delimited using "03-intermediate-data/Endline-Rain-Google-EE/atai_rainfall_ee.csv", clear
drop systemindex geo

duplicates drop id date, force //There is one duplicate ID in the shapefile, 03v32f0954

rename mean rain_daily_ 

destring date, ignore(-) replace

* This is in mm/hr, but we want mm/day so units are more manageable 
replace rain_daily_ = 24*rain_daily_

* Reshape to wide 
reshape wide rain_daily_ , i(id) j(date)

foreach x of varlist rain* { 
  label var `x' "Rainfall (mm/day)"
}

tempfile rainfall
save `rainfall'

restore 

merge 1:1 id using `rainfall', assert(3) nogenerate


rename area calc_area_acre

drop if id == "-04 125246" | id == "05f0125c-1"

generate uid = upper(id) if strpos(substr(upper(id),1,1),"B")
replace uid = "B" + upper(id) if missing(uid)

replace uid = "B02V15F0449" if uid == "B0215F0449"
replace uid = "B03V27F0820" if uid == "B03V270820" 
replace uid = "B03V28F0833" if uid == "B03V280833"
replace uid = "B04V46F1311" if uid == "B04V461311"
replace uid = "B05V59F1635" if uid == "B05V591635"
replace uid = "B05V65F1827" if uid == "B05V65F827"
replace uid = "B02V22F0676" if uid == "B20V22F0676"

*Typos
replace uid = "B03V35F1040" if uid == "B01V35F1040"
replace uid = "B02V17F0510" if uid == "B02V15F0510"
replace uid = "B02V25F0759" if uid == "B02V25F0769"
replace uid = "B03V35F1023" if uid == "B02V35F1023"
replace uid = "B03V36F1079" if uid == "B03V36F1179"
drop if uid == "B06V74F2241" // This got flagged as a duplicate, and the dup value has an identical area
replace uid = "B04V53F1464C1"  if uid == "BV53F1464 1"
replace uid = "B01V02F0061" if uid == "B01V02F0066"
replace uid = "B02V17F0514" if uid == "B02V14F0514"
replace uid = "B06V73F2048" if uid == "B0V73F2048"

*Long name in gpx files
replace uid = "B05V64F1776" if uid == "1776125850"
replace uid = "B05V64F1786" if uid == "1786153648"
replace uid = "B05V64F1787" if uid == "1787105420"
replace uid = "B05V64F1791" if uid == "1791164601"

replace uid = "B02V24F0719" if id == "02v24f0702"
drop if id == "2218113630" // This got flagged as a duplicate, and the dup has an identical area
drop if id == "2240133433" // This got flagged as a duplicate, and the dup has an identical area 
replace uid = "B01V02F0061" if id == "b01v02f0066"

replace uid = "B05V64F1776" if uid == "B1776125850"
replace uid = "B05V64F1786" if uid == "B1786153648"
replace uid = "B05V64F1787" if uid == "B1787105420"
replace uid = "B05V64F1791" if uid == "B1791164601"

drop id

//Next, standardize the indicators for the "cotton plot" map
replace uid = subinstr(uid,"_C1","C1",.)
replace uid = subinstr(uid,"_C2","C2",.)
replace uid = subinstr(uid," C1","C1",.)
replace uid = subinstr(uid," C2","C2",.)
replace uid = subinstr(uid,"-C1","C1",.)
replace uid = subinstr(uid,"-C2","C2",.)
replace uid = subinstr(uid," C","C1",.)
replace uid = uid + "1" if substr(uid, -1, 1) ==  "C"

//Now split at C 
split uid, parse("C") destring 

drop uid 
rename uid1 uid 
rename uid2 cotton_section 

//A lot of the cotton plots did not have correct IDs, so we need to fix all of these
replace uid = "B01V05F0127" if uid == "BV05F0127"
replace uid = "B01V03F0069" if uid == "B03F0069"
replace uid = "B01V11F0332" if uid == "B11F0332"
replace uid = "B02V14F0416" if uid == "B14F0416"
replace uid = "B02V15F0425" if uid == "B15F0425"
replace uid = "B03V37F1082" if uid == "BV37F1082"
replace uid = "B06V72F2041" if uid == "B6V72F2041"
replace uid = "B05V66F1844" if uid == "B5V66F1844"
replace uid = "B05V57F1595" if uid == "B5V57F1595"
replace uid = "B04V45F1300" if uid == "BV45F1300"
replace uid = "B03V33F0985" if uid == "BV33F0985"
replace uid = "B01V12F0349" if uid == "BV12F0349"
replace uid = "B04V43F1231" if uid == "BV43F1231"
replace uid = "B04V53F1483" if uid == "BV53F1483"
replace uid = "B06V72F2038" if uid == "BV72F2038"
replace uid = "B03V33F0980" if uid == "BV33F0980"
replace uid = "B06V72F2040" if uid == "BV72F2040"
replace uid = "B05V65F1802" if uid == "BV65F1802"
replace uid = "B03V38F1127" if uid == "BV38F1127"
replace uid = "B04V50F1416" if uid == "BV50F1416"
replace uid = "B03V33F0983" if uid == "BV33F0983"
replace uid = "B03V30F0897" if uid == "BV30F0897"
replace uid = "B03V30F0883" if uid == "BV30F0888"
replace uid = "B03V34F0998" if uid == "BV34F0998"
replace uid = "B03V37F1102" if uid == "BV37F1111"
replace uid = "B06V73F2062" if uid == "BV73F2062"
replace uid = "B03V38F1141" if uid == "BV38F1141"
replace uid = "B03V27F0823" if uid == "BV27F0823"
replace uid = "B04V49F1389" if uid == "BV49F1389"
replace uid = "B03V31F0933" if uid == "BV31F0933"
replace uid = "B03V37F1089" if uid == "BV37F1089"
replace uid = "B03V35F1024" if uid == "BV35F1024"
replace uid = "B03V37F1095" if uid == "BV37F1095"
replace uid = "B06V73F2081" if uid == "BV73F2081"
replace uid = "B03V30F0907" if uid == "BV30F0907"
replace uid = "B02V23F0698" if uid == "BV23F0698"
replace uid = "B03V39F1163" if uid == "BV39F1163"
replace uid = "B03V38F1145" if uid == "BV38F1145"
replace uid = "B03V28F0842" if uid == "BV28F0842"
replace uid = "B03V29F0870" if uid == "BV29F0870"
replace uid = "B01V01F0010" if uid == "BV01F0010"
replace uid = "B04V55F1524" if uid == "BV55F1524"
replace uid = "B03V31F0909" if uid == "BV31F0909"
replace uid = "B06V72F2040" if uid == "BV72F2040"
replace uid = "B04V52F1438" if uid == "BV52F1438"
replace uid = "B03V27F0819" if uid == "BV27F0819"
replace uid = "B04V50F1413" if uid == "BV50F1413"
replace uid = "B03V35F1029" if uid == "BV35F1029"
replace uid = "B03V37F1086" if uid == "BV37F1086"
replace uid = "B04V54F1500" if uid == "BV54F1500"
replace uid = "B02V16F0468" if uid == "BV16F0468"
replace uid = "B06V75F2133" if uid == "BV75F2133"
replace uid = "B03V35F1032" if uid == "BV35F1032"
replace uid = "B04V54F1489" if uid == "BV54F1489"
replace uid = "B06V73F2081" if uid == "BV73F2081"
replace uid = "B03V34F0994" if uid == "BV34F0994"
replace uid = "B03V31F0940" if uid == "BV31F0940"
replace uid = "B03V39F1157" if uid == "BV39F1157"
replace uid = "B03V37F1110" if uid == "BV37F1110"
replace uid = "B04V51F1431" if uid == "BV51F1431"
replace uid = "B03V34F1013" if uid == "BV34F1013"
replace uid = "B03V35F1023" if uid == "BV35F1023"
replace uid = "B03V30F0886" if uid == "BV30F0886"
replace uid = "B02V16F0474" if uid == "BV16F0474"
replace uid = "B03V36F1051" if uid == "BV36F1051"
replace uid = "B03V34F0993" if uid == "BV34F0993"
replace uid = "B04V49F1395" if uid == "BV49F1395"
replace uid = "B03V31F0928" if uid == "BV31F0928"
replace uid = "B04V52F1443" if uid == "BV52F1443"
replace uid = "B06V76F2169" if uid == "BV76F2169"
replace uid = "B03V30F0887" if uid == "BV30F0887"
replace uid = "B06V81F2320" if uid == "BV81F2320"
replace uid = "B04V44F1261" if uid == "BV44F1261"
replace uid = "B03V35F1024" if uid == "BV35F1024"
replace uid = "B04V46F1310" if uid == "BV46F1310"
replace uid = "B03V37F1111" if uid == "BV37F1111"
replace uid = "B03V35F1035" if uid == "BV35F1035"
replace uid = "B03V38F1135" if uid == "BV38F1135"
replace uid = "B02V22F0665" if uid == "BV22F0665"
replace uid = "B02V15F0449" if uid == "BV15F0449"
replace uid = "B02V14F0423" if uid == "BV14F0423"
replace uid = "B03V37F1087" if uid == "BV37F1087"
replace uid = "B04V43F1237" if uid == "BV43F1237"
replace uid = "B03V39F1161" if uid == "BV39F1161"
replace uid = "B03V34F1015" if uid == "BV34F1010"
replace uid = "B03V33F0979" if uid == "BV33F0979"
replace uid = "B03V32F0945" if uid == "BV32F0945"
replace uid = "B04V52F1447" if uid == "BV52F1447"
replace uid = "B03V38F1116" if uid == "BV38F1116"
replace uid = "B03V28F0828" if uid == "BV28F0828"
replace uid = "B02V22F0652" if uid == "BV22F0652"
replace uid = "B01V09F0239" if uid == "BV09F0239"
replace uid = "B03V35F1028" if uid == "BV35F1028"
replace uid = "B04V48F1371" if uid == "BV48F1371"
replace uid = "B02V16F0478" if uid == "BV16F0478"
replace uid = "B02V17F0508" if uid == "BV17F0508"
replace uid = "B03V31F0923" if uid == "BV31F0923"
replace uid = "B04V50F1401" if uid == "BV50F1401"
replace uid = "B03V28F0826" if uid == "BV28F0828"
replace uid = "B03V39F1174" if uid == "BV39F1174"
replace uid = "B03V34F1006" if uid == "BV34F1006"
replace uid = "B02V26F0774" if uid == "BV26F0774"
replace uid = "B03V35F1037" if uid == "BV35F1037"
replace uid = "B04V43F1221" if uid == "BV43F1221"
replace uid = "B04V54F1487" if uid == "BV54F1487"
replace uid = "B04V54F1488" if uid == "BV54F1488"
replace uid = "B02V14F0405" if uid == "BV14F0405"
replace uid = "B01V03F0073" if uid == "BV03F0073"
replace uid = "B03V39F1178" if uid == "BV39F1178"
replace uid = "B02V17F0509" if uid == "BV17F0509"
replace uid = "B04V48F1360" if uid == "BV48F1360"
replace uid = "B04V55F1523" if uid == "BV55F1523"
replace uid = "B04V45F1299" if uid == "BV45F1299"
replace uid = "B03V37F1084" if uid == "BV37F1084"
replace uid = "B03V30F0897" if uid == "BV30F0897"
replace uid = "B03V38F1144" if uid == "BV38F1144"
replace uid = "B03V38F1132" if uid == "BV38F1132"
replace uid = "B02V24F0725" if uid == "BV24F0725"
replace uid = "B03V37F1102" if uid == "BV37F1102"
replace uid = "B02V26F0764" if uid == "BV26F0764"
replace uid = "B02V17F0518" if uid == "BV17F0518"
replace uid = "B03V36F1058" if uid == "BV36F1058"
replace uid = "B03V28F0843" if uid == "BV28F0843"
replace uid = "B03V39F1154" if uid == "BV39F1154"
replace uid = "B05V64F1792" if uid == "BV64F1792"
replace uid = "B03V37F1104" if uid == "BV37F1104"
replace uid = "B03V27F0824" if uid == "BV27F0824"
replace uid = "B04V46F1311" if uid == "BV46F1311"
replace uid = "B04V45F1298" if uid == "BV45F1298"
replace uid = "B03V33F0987" if uid == "BV33F0987"
replace uid = "B06V73F2065" if uid == "BV73F2065"
replace uid = "B01V04F0105" if uid == "BV04F0105"
replace uid = "B03V39F1150" if uid == "BV39F1150"
replace uid = "B03V32F0968" if uid == "BV32F0968"
replace uid = "B04V47F1345" if uid == "BV47F1345"
replace uid = "B06V75F2128" if uid == "BV75F2128"
replace uid = "B03V37F1081" if uid == "BV37F1081"
replace uid = "B02V16F0482" if uid == "BV16F0482"
replace uid = "B04V49F1395" if uid == "BV49F1395"
replace uid = "B03V34F0990" if uid == "BV34F0990"
replace uid = "B03V28F0834" if uid == "BV28F0834"
replace uid = "B06V81F2329" if uid == "BV81F2329"
replace uid = "B06V80F2305" if uid == "BV80F2305"
replace uid = "B01V12F0362" if uid == "BV12F0362"
replace uid = "B03V31F0915" if uid == "BV31F0915"
replace uid = "B04V55F1536" if uid == "BV55F1536"
replace uid = "B03V36F1053" if uid == "BV36F1053"
replace uid = "B04V55F1522" if uid == "BV55F1522"
replace uid = "B04V54F1507" if uid == "BV54F1507"
replace uid = "B03V31F0930" if uid == "BV31F0930"
replace uid = "B03V37F1100" if uid == "BV37F1110"
replace uid = "B04V46F1313" if uid == "BV46F1313"
replace uid = "B03V35F1032" if uid == "BV35F1032"
replace uid = "B04V50F1411" if uid == "BV50F1411"
replace uid = "B03V34F1010" if uid == "BV34F1010"
replace uid = "B04V47F1340" if uid == "BV47F1340"
replace uid = "B02V24F0721" if uid == "BV24F0721"
replace uid = "B03V38F1121" if uid == "BV38F1121"
replace uid = "B04V45F1293" if uid == "BV45F1293"
replace uid = "B04V47F1348" if uid == "BV47F1348"
replace uid = "B06V80F2304" if uid == "BV80F2304"
replace uid = "B03V37F1088" if uid == "BV37F1088"
replace uid = "B03V27F0798" if uid == "BV27F0798"
replace uid = "B04V44F1266" if uid == "BV44F1266"
replace uid = "B04V54F1494" if uid == "BV54F1494"
replace uid = "B04V54F1503" if uid == "BV54F1503"
replace uid = "B02V18F0544" if uid == "BV18F0544"
replace uid = "B03V32F0958" if uid == "BV32F0958"
replace uid = "B03V31F0910" if uid == "BV31F0910"
replace uid = "B02V16F0490" if uid == "BV16F0490"
replace uid = "B03V31F0934" if uid == "BV31F0934"
replace uid = "B03V32F0967" if uid == "BV32F0967"
replace uid = "B03V31F0917" if uid == "BV31F0917"
replace uid = "B06V81F2331" if uid == "BV81F2331"
replace uid = "B03V36F1070" if uid == "BV36F1070"
replace uid = "B03V31F0935" if uid == "BV31F0935"
replace uid = "B06V76F2153" if uid == "BV76F2153"
replace uid = "B02V19F0588" if uid == "BV19F0588"
replace uid = "B03V37F1105" if uid == "BV37F1105"
replace uid = "B03V33F0981" if uid == "BV33F0981"
replace uid = "B03V37F1088" if uid == "BV37F1088"
replace uid = "B03V32F0967" if uid == "BV32F0967"
replace uid = "B03V34F1011" if uid == "BV34F1011"
replace uid = "B04V46F1332" if uid == "BV46F1332"
replace uid = "B03V31F0920" if uid == "BV31F0920"
replace uid = "B03V32F0956" if uid == "BV32F0956"
replace uid = "B02V14F0402" if uid == "BV14F0402"
replace uid = "B03V34F0998" if uid == "BV34F0998"
replace uid = "B03V37F1107" if uid == "BV37F1107"
replace uid = "B03V27F0819" if uid == "BV27F0819"
replace uid = "B03V35F1038" if uid == "BV35F1038"
replace uid = "B03V37F1110" if uid == "BV37F1110"
replace uid = "B03V39F1170" if uid == "BV39F1170"
replace uid = "B03V31F0937" if uid == "BV31F0937"
replace uid = "B03V28F0830" if uid == "BV28F0830"
replace uid = "B06V81F2325" if uid == "BV81F2325"
replace uid = "B03V35F1021" if uid == "BV35F1021"
replace uid = "B04V55F1531" if uid == "BV55F1531"
replace uid = "B06V77F2199" if uid == "BV77F2199"
replace uid = "B02V16F0487" if uid == "BV16F0487"
replace uid = "B04V52F1451" if uid == "BV52F1451"
replace uid = "B03V36F1069" if uid == "BV36F1069"
replace uid = "B06V75F2144" if uid == "BV75F2144"
replace uid = "B03V35F1031" if uid == "BV35F1031"
replace uid = "B04V46F1317" if uid == "BV46F1317"
replace uid = "B03V28F0835" if uid == "BV28F0835"
replace uid = "B03V30F0904" if uid == "BV30F0904"
replace uid = "B04V50F1399" if uid == "BV50F1399"
replace uid = "B02V16F0484" if uid == "BV16F0484"
replace uid = "B04V55F1531" if uid == "BV55F1531"
replace uid = "B03V37F1103" if uid == "BV37F1103"
replace uid = "B02V18F0563" if uid == "BV18F0563"
replace uid = "B03V32F0950" if uid == "BV32F0950"
replace uid = "B03V34F1009" if uid == "BV34F1009"
replace uid = "B04V44F1273" if uid == "BV44F1273"
replace uid = "B02V21F0646" if uid == "BV21F0646"
replace uid = "B02V16F0493" if uid == "BV16F0493"
replace uid = "B04V51F1431" if uid == "BV51F1431"
replace uid = "B02V16F0492" if uid == "BV16F0492"
replace uid = "B04V55F1525" if uid == "BV55F1525"
replace uid = "B03V37F1091" if uid == "BV37F1091"
replace uid = "B04V51F1432" if uid == "BV51F1432"
replace uid = "B05V68F1914" if uid == "BV68F1914"
replace uid = "B04V49F1380" if uid == "BV49F1380"
replace uid = "B02V23F0699" if uid == "BV23F0699"
replace uid = "B02V22F0656" if uid == "BV22F0656"
replace uid = "B03V37F1101" if uid == "BV37F1101"
replace uid = "B02V16F0475" if uid == "BV16F0475"
replace uid = "B04V52F1445" if uid == "BV52F1445"
replace uid = "B04V46F1322" if uid == "BV46F1322"
replace uid = "B04V44F1259" if uid == "BV44F1259"
replace uid = "B03V39F1155" if uid == "BV39F1155"
replace uid = "B03V28F0848" if uid == "BV28F0848"
replace uid = "B01V12F0362" if uid == "BV12F0362"
replace uid = "B03V36F1061" if uid == "BV36F1061"
replace uid = "B02V14F0410" if uid == "BV14F0410"
replace uid = "B03V31F0932" if uid == "BV31F0932"
replace uid = "B04V54F1509" if uid == "BV54F1509"
replace uid = "B04V54F1495" if uid == "BV54F1495"
replace uid = "B03V36F1052" if uid == "BV36F1052"
replace uid = "B03V31F0925" if uid == "BV31F0925"
replace uid = "B03V31F0920" if uid == "BV31F0920"
replace uid = "B03V33F0989" if uid == "BV33F0989"
replace uid = "B04V49F1390" if uid == "BV49F1390"
replace uid = "B06V75F2133" if uid == "BV75F2133"
replace uid = "B02V18F0546" if uid == "BV18F0546"
replace uid = "B03V27F0806" if uid == "BV27F0806"
replace uid = "B02V14F0410" if uid == "BV14F0410"
replace uid = "B06V69F1936" if uid == "BV69F1936"
replace uid = "B06V73F2087" if uid == "BV73F2087"
replace uid = "B02V15F0458" if uid == "BV15F0458"
replace uid = "B03V37F1104" if uid == "BV37F1104"
replace uid = "B03V32F0945" if uid == "BV32F0945"
replace uid = "B03V32F0949" if uid == "BV32F0949"
replace uid = "B02V18F0534" if uid == "BV18F0534"
replace uid = "B03V30F0896" if uid == "BV30F0896"
replace uid = "B03V38F1142" if uid == "BV38F1142"
replace uid = "B03V36F1073" if uid == "BV36F1073"
replace uid = "B03V37F1096" if uid == "BV37F1096"
replace uid = "B03V30F0888" if uid == "BV30F0888"
replace uid = "B03V31F0919" if uid == "BV31F0919"
replace uid = "B04V46F1324" if uid == "BV46F1324"
replace uid = "B04V45F1275" if uid == "BV45F1275"
replace uid = "B04V47F1339" if uid == "BV47F1339"
replace uid = "B04V53F1471" if uid == "BV53F1471"
replace uid = "B02V24F0716" if uid == "BV24F0716"
replace uid = "B04V44F1251" if uid == "BV44F1251"
replace uid = "B03V39F1172" if uid == "BV39F1172"
replace uid = "B04V47F1349" if uid == "BV47F1349"
replace uid = "B01V12F0340" if uid == "BV12F0340"
replace uid = "B02V19F0590" if uid == "BV19F0590"
replace uid = "B03V30F0883" if uid == "BV30F0883"
replace uid = "B04V48F1365" if uid == "BV48F1365"
replace uid = "B01V08F0221" if uid == "BV08F0221"
replace uid = "B01V03F0091" if uid == "BV03F0091"
replace uid = "B04V51F1426" if uid == "BV51F1426"
replace uid = "B03V39F1172" if uid == "BV39F1172"
replace uid = "B03V31F0916" if uid == "BV31F0916"
replace uid = "B01V03F0079" if uid == "BV03F0079"
replace uid = "B05V57F1595" if uid == "BV57F1595"
replace uid = "B03V31F0921" if uid == "BV31F0921"
replace uid = "B03V34F1005" if uid == "BV34F1005"
replace uid = "B03V37F1091" if uid == "BV37F1091"
replace uid = "B03V35F1040" if uid == "BV35F1040"
replace uid = "B03V37F1109" if uid == "BV37F1109"
replace uid = "B01V07F0198" if uid == "BV07F0198"
replace uid = "B03V27F0817" if uid == "BV27F0817"
replace uid = "B03V39F1165" if uid == "BV39F1165"
replace uid = "B04V54F1500" if uid == "BV54F1500"
replace uid = "B04V43F1240" if uid == "BV43F1240"
replace uid = "B03V31F0939" if uid == "BV31F0939"
replace uid = "B01V13F0390" if uid == "BV13F0390"
replace uid = "B03V35F1021" if uid == "BV35F1021"
replace uid = "B04V53F1478" if uid == "BV53F1478"
replace uid = "B02V18F0560" if uid == "BV18F0560"
replace uid = "B03V31F0938" if uid == "BV31F0938"
replace uid = "B06V77F2195" if uid == "BV77F2195"
replace uid = "B03V29F0879" if uid == "BV29F0879"
replace uid = "B04V45F1277" if uid == "BV45F1277"
replace uid = "B01V01F0004" if uid == "BV01F0004"
replace uid = "B03V36F1056" if uid == "BV36F1056"
replace uid = "B06B74F2108" if uid == "B74F2108"
replace uid = "B06V74F2108" if uid == "B06B74F2108"
replace uid = "B06V81F2316" if uid == "BV81F2316"
replace uid = "B04V51F1424" if uid == "B51F1424"
replace uid = "B06V80F2309" if uid == "B80F2306"
replace uid = "B06V76F2157" if uid == "B76F2157"
replace uid = "B04V46F1320" if uid == "B46F1320"
replace uid = "B04V49F1392" if uid == "B49F1392"
replace uid = "B02V15F0450" if uid == "B15F0450"
replace uid = "B02V19F0580" if uid == "B19F0580"
replace uid = "B06V69F1941" if uid == "B69F1941"
replace uid = "B06V81F2333" if uid == "B81F2333"
replace uid = "B02V17F0511" if uid == "B17F0511"
replace uid = "B06V69F1944" if uid == "B69F1944"
replace uid = "B04V47F1352" if uid == "B47F1352"
replace uid = "B02V21F0623" if uid == "B21F0623"
replace uid = "B06V69F1938" if uid == "B69F1938"
replace uid = "B06V76F2155" if uid == "B76F2155"
replace uid = "B02V21F0628" if uid == "B21F0628"
replace uid = "B06V76F2164" if uid == "B76F2164"
replace uid = "B04V51F1419" if uid == "B51F1419"
replace uid = "B06V80F2306" if uid == "B80F2306"
replace uid = "B03V37F1106" if uid == "B3V371106"
replace uid = "B03V31F0938" if uid == "B3V310938"
replace uid = "B03V27F0801" if uid == "B3V270801"
replace uid = "B06V80F2285" if uid == "B6V80F2285"
replace uid = "B02V14F0411" if uid == "BV14F0411"
replace uid = "B06V81F2326" if uid == "BV81F2326"
replace uid = "B02V15F0462" if uid == "B02V15F0662"
replace uid = "B01V11F0301" if uid == "BV11F0301"
replace uid = "B01V05F0128" if uid == "BV05F0128"
replace uid = "B02V16F0472" if uid == "BV16F0472"
replace uid = "B04V55F1532" if uid == "BV55F1532"
replace uid = "B04V52F1449" if uid == "BV52F1449"
replace uid = "B04V50F1405" if uid == "BV50F1405"
replace uid = "B04V47F1334" if uid == "BV47F1334"
replace uid = "B04V46F1316" if uid == "BV46F1316"
replace uid = "B04V45F1281" if uid == "BV45F1281"
replace uid = "B04V45F1278" if uid == "BV45F1278"
replace uid = "B02V26F0784" if uid == "BV26F0784"
replace uid = "B02V24F0718" if uid == "BV24F0718"
replace uid = "B02V16F0489" if uid == "BV16F0489"
replace uid = "B01V11F0306" if uid == "BV11F0306"
replace uid = "B04V55F1535" if uid == "B55F1535"

//First, we will save a dataset that just has the full plot maps

generate full_plot = cond(missing(cotton_section), 1, 0) 

foreach x of varlist mtci* { 
destring `x', force replace
}

preserve
keep if full_plot == 1
drop full_plot cotton_section

foreach var of varlist mtci* re705* ndvi* lai* gcvi* ndwi* planet* placebo* {
  rename `var' p_`var'
  label var p_`var' "Full plot measurements"
}

replace calc_area_acre = 2.5*calc_area_acre
rename calc_area_acre calc_plot_area 
label var calc_plot_area "Area (bigha) calculated from plot boundaries"

isid uid 

tempfile fullPlots
save `fullPlots'
restore 

//Second, we will calculate the cotton area stats then merge in the full plot stats and save a final file 
duplicates tag uid, gen(dup)
foreach var of varlist re705* ndvi* lai* gcvi* ndwi* planet* calc_area_acre placebo* {
  replace `var' = . if dup > 0 & full_plot == 1
}

drop dup full_plot cotton_section

collapse (mean) mtci* re705* ndvi* lai* gcvi* ndwi* ///
placebo_mtci* placebo_re705* placebo_ndvi* placebo_lai* placebo_gcvi* placebo_ndwi* planet* (sum) calc_area_acre, by(uid)

replace calc_area_acre = 2.5*calc_area_acre
rename calc_area_acre calc_cotton_area 
label var calc_cotton_area "Cotton area (bigha) calculated from plot boundaries"

foreach var of varlist mtci* re705* ndvi* lai* gcvi* ndwi* planet* placebo* {
  rename `var' c_`var' 
  label var c_`var' "Cotton area measurements"
}

merge 1:1 uid using `fullPlots', nogenerate

order uid calc_plot_area calc_cotton_area

//Fix instances where the cotton and full plot maps were mixed up
tempvar temp 
generate `temp' = calc_plot_area
tempvar switch
generate `switch' = cond(calc_cotton_area > calc_plot_area + .01, 1, 0)
replace calc_plot_area = calc_cotton_area if `switch' == 1
replace calc_cotton_area = `temp' if `switch' == 1

foreach var of varlist p_* {
  replace `temp' = `var' 
  local var_stub = substr("`var'",2,.)
  local var2 = "c`var_stub'"
  replace `var' = `var2' if `switch' == 1
  replace `var2' = `temp' if `switch' == 1
}

assert calc_cotton_area <= calc_plot_area + .01 

// Save rainfall and the rest of the data in separate files since rainfall includes so many variables 

preserve 
keep rain* uid  
save "04-output-data/rainfall.dta", replace 
restore 

drop rain* 
save "04-output-data/zonalStats.dta", replace 

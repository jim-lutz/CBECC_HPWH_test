<<<<<<< HEAD
# hwdp_aquacraft
R scripts for analyzing Aquacraft data for California Title 24 hot water draw patterns

in ../Aquacraft use these scripts to extract data for processing with R
access2csv.sh  catheadcsv.sh  headcsv.sh
extract_headers.pl

load_CA.R
load and evaluate CA data

loadtemp.R
loads, cleans and summarizes data from hot houses in REUWS2
  input:  tblMains_for_Hots
          tblHotTraces_REUWS2
          Combined Hot Water Audit Forms.csv
  output: DT_temp_events.Rdata
          event.summary.csv
          event.ends.csv        # first and last draw by type & Keycode to search for non overlap hot & mains
          
          
  







=======
# CBECC_HPWH_test
>>>>>>> 6b5d1312bac3215a0a35a9ef689b9ef23cf74150

# functions.R
# set of functions to use when processing CBECC output files

addHoY  <- function (name.of.DT_8760){
  # adds hour of year to an hourly data.table which is called by name
  get(name.of.DT_8760)[,HoY:=seq_len(8760)]
}


library(tidyverse)
library(parallel)

df <- readLines('data/stripped')
lines <- df[5:length(df)]
str(lines)
head(lines)
tail(lines)


step1 <- function(line){
  values <- unlist(strsplit(line, ","))
  first_value <- trimws(values[1], "right")
  other_values <- as.numeric(values[-1])
  temp_df <- data.frame(id = first_value, numbers = other_values, order= 1:length(other_values),stringsAsFactors = FALSE)
  return(temp_df)
}


f_parLapply <- function(lines){
  res <- parLapply(cl, lines, step1)
  result=as.data.frame(do.call(rbind,res))
  return(result)
}

cl <- makeCluster(detectCores())
clusterExport(cl, varlist = c("step1", "lines"))

stripped <- f_parLapply(lines)
head(stripped)
tail(stripped)
str(stripped)
saveRDS(stripped,file="data/stripped.RDS")

library(tidyverse)
library(microbenchmark)
library(parallel)
library(foreach)
library(doParallel)

df <- readLines('data/stripped')
df1 <- df[5:length(df)]
str(df1)
head(df1)
tail(df1)


step1 <- function(line){
  values <- unlist(strsplit(line, ","))
  first_value <- values[1]
  other_values <- values[-1]
  temp_df <- data.frame(FirstValue = first_value, SecondValue = other_values, stringsAsFactors = FALSE)
  return(temp_df)
}

#--------------------------
#test1 step1 with sapply
#--------------------------
f_sapply <- function(lines) {
  res <- sapply(lines,function(x) step1(x),simplify = F)
  names(res) <- NULL
  res1 <- do.call(rbind,res)
  return(res1)
}

#--------------------------
#test2 step1 in loop
#--------------------------
f_loop <- function(lines){
  result <- data.frame(FirstValue = character(), SecondValue = character(), stringsAsFactors = FALSE)
  # Process each line
  for (line in lines) {
    # Split the line by comma
    values <- unlist(strsplit(line, ","))
    # Extract the first value
    first_value <- values[1]
    # Extract the remaining values
    other_values <- values[-1]
    # Create a data frame for the current line
    temp_df <- data.frame(FirstValue = first_value, SecondValue = other_values, stringsAsFactors = FALSE)
    # Bind to the result data frame
    result <- rbind(result, temp_df)
  }
  row.names(result) <- NULL
  return(result)
}

#---------------------------------
#test3 paralel loop with foreach
#---------------------------------
f_foreach <- function(lines){
  
  # num_cores <- detectCores()
  # cl <- makeCluster(num_cores)
  # registerDoParallel(cl)
  
  result <- data.frame(FirstValue = character(), SecondValue = character(), stringsAsFactors = FALSE)
  result <- foreach(line = lines, .combine = rbind, .packages = "stringr") %dopar% {
    # Split the line by comma
    values <- unlist(strsplit(line, ","))
    # Extract the first value
    first_value <- values[1]
    # Extract the remaining values
    other_values <- values[-1]
    # Create a data frame for the current line
    temp_df <- data.frame(FirstValue = first_value, SecondValue = other_values, stringsAsFactors = FALSE)
    return(temp_df)
  }
  # stopCluster(cl)
  return(result)
}


#-----------------------------------
#test4 step1 paralel with parLapply
#-----------------------------------
f_parLapply <- function(lines){
  # cl <- makeCluster(detectCores())
  # clusterExport(cl, varlist = c("step1_test1", "lines"))
  res <- parLapply(cl, lines, step1)
  result=as.data.frame(do.call(rbind,res))
  # stopCluster(cl)
  return(result)
}
#check result is ok
#doing clusters outside funtions....


cl <- makeCluster(detectCores())
#for parLapply
clusterExport(cl, varlist = c("step1", "lines"))
#for foreach
registerDoParallel(cl)

lines <- df1[1:2]
f_sapply(lines)
f_loop(lines)
f_foreach(lines)
f_parLapply(lines)


check <- data.frame()
<<<<<<< HEAD
for(n in c(10,100,200)){
  lines <- df1[1:n]
  print(n)
  benchmark_result <- microbenchmark(
    f_sapply(lines),
    f_loop(lines),
    f_foreach(lines),
    f_parLapply(lines),
    times = 10  # Number of times to run each function
  )

check <- rbind(check,cbind(data.frame(n=n,summary(benchmark_result))))
}

stopCluster(cl)
print(check)
ggplot(check)+geom_line(aes(n,mean,color=expr))






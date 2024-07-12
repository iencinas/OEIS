
directory_path <- '~/R/oeisdata/seq/'
all_files <- list.files(path = directory_path, recursive = TRUE, full.names = TRUE)
head(all_files)

test <- all_files[1]
all_lines <- readLines(test)
y_lines <- grep("^%Y", all_lines, value = TRUE)
print(y_lines)

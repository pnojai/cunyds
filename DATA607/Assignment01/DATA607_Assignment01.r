
# Data Source: https://archive.ics.uci.edu/ml/datasets/Mushroom
# Download Date: 8/31/2019

library(data.table)

assign_dir <- "./DATA607/Assignment01"
dat_fil <- "agaricus-lepiota.data"

dat <- fread(file = paste(assign_dir, dat_fil, sep = "/"),
      sep = ",",
      header = FALSE)



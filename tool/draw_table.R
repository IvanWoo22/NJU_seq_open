#!/usr/bin/env Rscript
library(ggplot2)
library(ggpubr)

args <- commandArgs(T)

mydata <- read.table(file('stdin'), row.names = 1, header = F)
mydata[, 1] <- gsub(" ", "", prettyNum(mydata[, 1], big.mark = ","))
mydata[, 2] <- gsub(" ", "", prettyNum(mydata[, 2], big.mark = ","))
colnames(mydata) [1:4] <-
  c("Total reads", "Aligned reads", "Alignment rate", "Time")

p <-
  ggtexttable(
    mydata,
    theme = ttheme(
      rownames.style = rownames_style(
        color = "white",
        fill = "#630460",
        face = "bold",
        hjust = 0.5,
        x = 0.5,
        linecolor = "#ffffff"
      ),
      colnames.style = colnames_style(
        color = "white",
        fill = "#630460",
        face = "bold",
        linecolor = "#ffffff"
      ),
      tbody.style = tbody_style(
        color = "black",
        fill = "transparent",
        linecolor = "#630460"
      )
    )
  )

rheight = 3 + nrow(mydata) * 0.15

result_save_path <- args[1]
ggsave(
  result_save_path,
  plot = p,
  device = "pdf",
  width = 8,
  height = rheight,
  dpi = "retina"
)
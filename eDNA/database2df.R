
# setwd("yourwd")

# ==============================================================================

library(RJSONIO)
library(dplyr)
#Input json file
database <- RJSONIO::fromJSON("./data/Database.json")
#Delete first element
information <- database[[1]]
print(information)
database[[1]] <- NULL

# extract eDNA data
database <- database[which(grepl("Fish_eDNA", database))]

# Select from database ----------------------------------------------------

sample_list <- read.csv("./data/sample_list.csv")

df_merge <- NULL
for (i in 1:nrow(sample_list)) {
  
  sample <- sample_list[i, ]

  for (j in 1:length(database)){
    
    d <- database[[j]]
    
    if ( (d$Site %in% sample$Project) &
         (d$Location %in% sample$Location) ){
      
      sample_list[i, "lat"] <- d$latitude
      sample_list[i, "long"] <- d$longitude

      # loop for sample
      for (k in 1:length(d$Fish_eDNA)){
        
        d_eDNA <- d$Fish_eDNA[[k]]
        
        if ((d_eDNA$analysis == "metabarcoding") &
            # (d_eDNA$day == sample$day) &
            (d_eDNA$year == sample$year ) &
            (d_eDNA$month == sample$month)){
          
          sample_list[i, "day"] <- d_eDNA$day
          sample_list[i, "hour"] <- d_eDNA$hour
          sample_list[i, "location"] <- d_eDNA$location
          sample_list[i, "depth_m"] <- d_eDNA$depth_m
          sample_list[i, "Sampler"] <- d_eDNA$Sampler
          sample_list[i, "volume_L"] <- d_eDNA$volume_L
          sample_list[i, "filter"] <- d_eDNA$filter
          sample_list[i, "extractor_analyzer"] <- d_eDNA$extractor_analyzer
          sample_list[i, "extraction"] <- d_eDNA$extraction
          sample_list[i, "primers"] <- d_eDNA$primers
          sample_list[i, "machine"] <- d_eDNA$machine
          sample_list[i, "analysis"] <- d_eDNA$analysis
  
          #Select
          organisms <- d_eDNA$organisms
          
          df <- do.call(rbind, lapply(organisms, function (x) {
            data.frame(Species = x$Species, No_reads = x$No_reads)
            }))
          
          # aggregate same species
          df <- aggregate(df$No_read, by = list(df$Species), FUN = sum)
          colnames(df) <- c("Species", sample$sample)
          
          if (!length(unique(df$species)) == length(df$species)) {
            print(name)
            stop()
          }
          
          if (is.null(df_merge)) {
            df_merge <- df
          } else {
            df_merge <- full_join(df_merge, df, by = "Species")
          }
          
        }
      }
    }
  }
  print(sample$sample)
}

# transform
df_merge[is.na(df_merge)] <- 0
df <- as.data.frame(t(df_merge))
colnames(df) <- df["Species", ]
df <- df[rownames(df) != "Species", ]
df <- cbind(sample = rownames(df), df)

write.csv(df, "./output/df.csv", row.names = F)
write.csv(sample_list, "./output/sample_info.csv", row.names = F)

print("Finish")

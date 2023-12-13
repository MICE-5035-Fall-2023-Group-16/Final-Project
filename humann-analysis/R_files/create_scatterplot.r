#    Final project - Group 16
#    MICE 5035 Personal Microbiome Analysis
#    12 December 2023
#
#    Run with:
#        Rscript create_scatterplot.r

# Get metadata
map <- read.delim("./map.txt", as.is=FALSE, row=1)

# Get path abundance data
pathway_abundance <- read.delim("./path_abundance.txt")

# Get food categories used to calculate diversity score
categories <- c("num_types_fruit_Cat", "num_types_veg_Cat", "seafood_per_week_Cat", "serv_whole_grains_fruits_veg_Cat", "serve_dairy_Cat", "serve_fermented_Cat")

# Get columns of identified pathways only
remove_columns <- c("sample_id", "UNMAPPED", "UNINTEGRATED", "UNINTEGRATED.unclassified", "sample_id.1")
selected_pathways <- pathway_abundance[, !(colnames(pathway_abundance) %in% remove_columns)]

# Initialize dictionary of pathway counts
sig_pathways <- rep(0, length(selected_pathways))
sig_pathways <- setNames(sig_pathways, colnames(selected_pathways))

# For each category, check if pathway is significant
# If yes, increment its count
wilcox_df <- data.frame(category=character(),pathway=character(),p_value=integer(),is_significant=logical())
for (cat in categories) {
  map[[cat]] <- factor(map[[cat]],levels=c("High","Low"))
  table(map[[cat]])
  ix <- map[[cat]] == "High"
  high_samples <- map$sample_id[ix]
  for (col in colnames(selected_pathways)) {
    pathway <- selected_pathways[[col]]
    results <- wilcox.test(selected_pathways[high_samples, col], ties.method="average", exact=FALSE)
    # Checks if the column is all zeros, meaning the pathway doesn't appear in any sample
    # Also checks if p-value is significant
    # Also checks that p-value is not NA
    if (sum(pathway) > 0 && results$p.value < 0.05 && !is.na(results$p.value)) {
      sig_pathways[col] <- sig_pathways[col] + 1
      wilcox_df <- rbind(wilcox_df,c(cat,col,results$p.value,TRUE))
    }
    else {
      wilcox_df <- rbind(wilcox_df,c(cat,col,results$p.value,FALSE))
    }
  }
}
# Convert dictionary to data frame
# Remove 0 and NA values
sig_pathways_df <- data.frame(pathway=names(sig_pathways),count=sig_pathways)
sig_pathways_df <- sig_pathways_df[sig_pathways_df$count > 0 & !is.na(sig_pathways_df$count),]

# Initialize dictionary of pathway counts per sample
pathway_counts_per_sample <- rep(0, length(map$sample_id))
pathway_counts_per_sample <- setNames(pathway_counts_per_sample, map$sample_id)
for (pathway in sig_pathways_df$pathway) {
  for (id in map$sample_id) {
    if (selected_pathways[id, pathway] > 0) {
      pathway_counts_per_sample[id] <- pathway_counts_per_sample[id] + 1
    }
  }
}
# Convert dictionary to data frame
# Remove NA values
sample_pathways_df <- data.frame(sample_id=names(pathway_counts_per_sample),count=pathway_counts_per_sample)
sample_pathways_df <- sample_pathways_df[!is.na(sample_pathways_df$count),]

# Create a scatter plot of diet diversity vs. pathway abundance
plot(map$diversity_score,sample_pathways_df$count,main="Diet diversity vs. pathway abundance",xlab="Diversity score",ylab="Abundance level",col="darkorange1",pch=16)
legend("topleft",legend="Sample",c="darkorange1",pch=16,cex=0.75)
abline(lm(sample_pathways_df$count ~ map$diversity_score))

# Save data frames to csv files
colnames(wilcox_df) <- c("category","pathway","p_value","is_significant")
write.csv(wilcox_df,"./wilcox_df.csv",row.names=FALSE,quote=FALSE)
write.csv(sig_pathways_df,"./sig_pathways_df.csv",row.names=FALSE,quote=FALSE)
write.csv(sample_pathways_df,"./sample_pathways_df.csv",row.names=FALSE,quote=FALSE)

# Save pathways with a significant p-value (< 0.005) to csv file
significant <- subset(wilcox_df,is_significant==TRUE,select=-is_significant)
write.csv(significant,"./wilcox_significant_df.csv",row.names=FALSE,quote=FALSE)

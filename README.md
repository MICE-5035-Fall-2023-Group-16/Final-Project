# Processed-Data
The GroupProject folder has all of the processed data files needed for R visualization. 
For step 5 in tutorial2, I did rarify the data (depth around 8,500 to include all samples) and I removed OTUs not present in atleast 2 samples.
single_rarefaction.py -i otus/otu_table.biom -d 8500 -o otus/otu_table_rarefied.biom
filter_otus_from_otu_table.py -i otus/otu_table_rarefied.biom -o otus/otu_table_final.biom -s 2

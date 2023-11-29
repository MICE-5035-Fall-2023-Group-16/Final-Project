# Processed-Data
The GroupProject folder has all of the processed data files needed for R visualization. 
For step 5 in tutorial2, I did rarify the data (depth around 8,500 to include all samples) and I removed OTUs not present in atleast 2 samples.

single_rarefaction.py -i otus/otu_table.biom -d 8500 -o otus/otu_table_rarefied.biom

filter_otus_from_otu_table.py -i otus/otu_table_rarefied.biom -o otus/otu_table_final.biom -s 2

---

### List of steps

1. Make a new folder to put the data.
```
mkdir final_project
cd final_project
```

2. Run SHI7 (like in Tutorial 1).
```
# run shi7 on the paired-end wgs data, keep separate fasta files in the output
time python3 /home/knightsd/public/shi7/shi7.py -i /home/mice5035/public/2023-fall/classdata/rawdata/ -o wgs-output --combine_fasta False

# note: the output files have an extra ".fa" in their name
# this will mess up our sample IDs later; we could fix it
# manually with "mv" but it's faster to use a loop like this:
cd wgs-output
for f in *.fa.fna; do echo $f; mv $f `basename $f .fa.fna`.fna; done
cd ..
```

3. Load software.
```
module load qiime/1.9.1_centos7
module load bowtie2
module load kraken
```

4. Run Kraken.
```
mkdir kraken-out

# loop through every .fna file. Run kraken2 on it.
for f in wgs-output/*.fna; do echo $f; time kraken2 --db /home/knightsd/public/minikraken2_v1_8GB --use-mpa-style --output tmp --report kraken-out/`basename $f .fna`.txt --use-names $f; done
```

5. Merge the separate Kraken outputs to taxon tables.
```
# Now we have a single output file per sample;
# we can merge these using the script kraken2table.py in this repo:
wget https://raw.githubusercontent.com/danknights/mice5035/master/scripts/kraken2table.py
python kraken2table.py kraken-out/*.txt taxon_tables
```

6. Convert each taxonomy table to biom format if you want to perform beta diversity and alpha diversity analysis using QIIME.
```
for f in taxon_tables/*.txt; do echo $f; biom convert -i $f --to-json -o `dirname $f`/`basename $f .txt`.biom --process-obs-metadata taxonomy; done
```

7. Get a summary of the OTU species table to determine a good depth cutoff for rarefaction.
```
biom summarize-table -i taxon_tables/taxa_table_L7.biom -o stats.txt
```

8. Rarefy species-level taxon table.
```
# Perform rarefaction
single_rarefaction.py -i taxon_tables/taxa_table_L7.biom -d 8448 -o taxon_tables/taxa_table_L7_rarefied.biom
```

9. Filter rarefied taxon table.
```
# filter species in < 2 samples
filter_otus_from_otu_table.py -i taxon_tables/taxa_table_L7_rarefied.biom -o taxon_tables/taxa_table_L7_final.biom -s 2
```

10. Run alpha and beta diversity analyses on final taxon table.
```
# run alpha and beta diversity analysis without tree-based metrics
alpha_diversity.py -m "chao1,observed_otus,shannon" -i taxon_tables/taxa_table_L7_final.biom -o alpha-diversity.txt
beta_diversity.py -i taxon_tables/taxa_table_L7_final.biom -o beta -m "bray_curtis,binary_jaccard"
```

11. Create emperor visualization graphs.
```
# Optionally run principal coordinates and 3D plots
# can also do this in R as in Tutorial 5
principal_coordinates.py -i beta/bray_curtis_taxa_table_L7_final.txt -o beta/bray_curtis_taxa_table_L7_final_pc.txt
principal_coordinates.py -i beta/binary_jaccard_taxa_table_L7_final.txt -o beta/binary_jaccard_taxa_table_L7_final_pc.txt

make_emperor.py -i beta/bray_curtis_taxa_table_L7_final_pc.txt -m /home/mice5035/public/2023-fall/class-metadata-v2.txt -o 3dplots-bray-curtis
make_emperor.py -i beta/binary_jaccard_taxa_table_L7_final_pc.txt -m /home/mice5035/public/2023-fall/class-metadata-v2.txt -o 3dplots-binary-jaccard
```

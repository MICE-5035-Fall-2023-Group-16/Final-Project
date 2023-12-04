⚠️STILL A WORK IN PROGRESS⚠️

## Installing Miniconda on MSI

The following commands to install Miniconda are taken from https://docs.conda.io/projects/miniconda/en/latest/ under *Quick command line install* > *Linux*.

```bash
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh

~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh
```

## Installing HUMANN on MSI

Follow the commands under *Install via conda* in the [instructions page](https://huttenhower.sph.harvard.edu/humann/)
(Note: install via pypi works best)

## Upgrading databases
You will need to upgrade your databases for HUMANN to work on your data. The following commands to upgrade databases are taken from https://huttenhower.sph.harvard.edu/humann/ under *Upgrading your databases*.
```bash
humann_databases --download chocophlan full /path/to/databases --update-config yes
humann_databases --download uniref uniref90_diamond /path/to/databases --update-config yes
humann_databases --download utility_mapping full /path/to/databases --update-config yes
```

Note: You can find `/path/to/databases` by running `humann -help` then copying the `DEFAULT` value of a database flag (i.e., –nucleotide-database, –protein-database) excluding the endfile of the path. Might look something like: `/home/mice5035/x500/miniconda3/envs/biobakery3/lib/python3.7/site-packages/humann/data/`

## Running HUMANN on MSI

1. Make a new folder to put the data.
```bash
# make output directory
mkdir humann_output
```

2. Copy class data into current folder.
```bash
# Copy classdata folder into current folder (final_project)
cp -r /home/mice5035/public/2023-fall/classdata .
```

3. Run HUMANN.
```bash
# run humans with 4 threads on each input file; can adjust if more CPUs are available
for f in classdata/rawdata/*R1.fastq.gz ; do echo $/f; /usr/bin/time -v humann -i $f -o humann_output -v --threads 4; done

cd humann_output
```

4. Normalize output.
```bash
# These steps are for normalizing output
for f in *genefamilies.tsv; do echo $f; humann_renorm_table --input $f --output `basename $f .tsv`_relab.tsv; done
for f in *pathabundance.tsv; do echo $f; humann_renorm_table --input $f --output `basename $f .tsv`_relab.tsv; done
```

5. Merge output tables into a single table.
```bash
# these steps are for merging all of the per-sample
# output tables into a single table per output type
echo "join gene families..."
humann_join_tables --input . --output humann_genefamilies.tsv --file_name genefamilies_relab
echo "join path coverage..."
humann_join_tables --input . --output humann_pathcoverage.tsv --file_name pathcoverage
echo "join path abundance..."
humann_join_tables --input . --output humann_pathabundance.tsv --file_name pathabundance_relab
```

6. Remove taxonomic labeled genes.
```bash
# remove taxonomic labeled genes, just retain total count per gene
# this reduces file size and can make the analysis easier
grep -v "UNMAPPED\||" humann_genefamilies.tsv > humann_genefamilies_general.tsv
```

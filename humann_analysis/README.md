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

## Upgrading databases
You will need to upgrade your databases for HUMANN to work on your data. The following commands to upgrade databases are taken from https://huttenhower.sph.harvard.edu/humann/ under *Upgrading your databases*.
```bash
humann_databases --download chocophlan full /path/to/databases --update-config yes
humann_databases --download uniref uniref90_diamond /path/to/databases --update-config yes
humann_databases --download utility_mapping full /path/to/databases --update-config yes
```

Note: You can find `/path/to/databases` by running `humann -help` then copying the `DEFAULT` value of a database flag excluding the endfile of the path (i.e., –nucleotide-database, –protein-database)

## Running HUMANN on MSI

```bash
# make output directory
mkdir humann_output
```

```bash
# Copy classdata folder into current folder (final_project)
cp -r /home/mice5035/public/2023-fall/classdata .
```

```bash
# run humans with 4 threads on each input file; can adjust if more CPUs are available
for f in classdata/rawdata/*R1.fastq.gz ; do echo $/f; /usr/bin/time -v humann -i $f -o humann_output -v --threads 4; done

cd humann_output
```

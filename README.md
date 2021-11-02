# SRAMicrobiomeCategoryPipeline
Scrape microbiomes from the SRA archive (ncbi) and build a classifier - Pipeline


First run the scrapeSRA.py script to get all micribiome data

Then run the *** perl script to consolidate a data table including each category

Then apply learning through the Jupyter notebook and store the model as a .pkl file

An application is built on deepnote with a connection to anvil, see:
- deepnote notebook:
- anvil script:

Users can upload csv files (comma separated) where columns are microbial taxa, that
- Has To Contain the taxon "Bacteria" as this is used as a baseline
- Has one column with column name "Name" and row values are sample names
- All other row values are frequencies (percentage or fraction) of taxon coverage

Example:
_____________________________
|Name, Bacteria, Bacilli, ...     
|Skin1, 80, 3, ...
|

# Occurrence data

The occurrence records used in the exploratory analysis are separated by provenance:

- `occurrences_combined.csv`: working table combining new records supplied for the manuscript and the georeferenced GBIF localities, with review notes and source identifiers.
- `gbif_download_0009689.tsv`: formal GBIF download (9 records; 8 with coordinates) associated with DOI [10.15468/dl.p33n36](https://doi.org/10.15468/dl.p33n36).
- `new_records_supplied.txt`: source text supplied by the authors for the new records.

The model used 17 unique coordinate localities after consolidation and retained 14 occupied environmental cells after Wallace preprocessing. Records without coordinates were excluded from model fitting. The occurrence table is a working analytical product; voucher, datum, coordinate uncertainty and taxonomic review should be reconciled against the final specimen table before public release.
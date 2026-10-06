# Scytodes panamensis SDM

Reproducible exploratory climatic suitability modelling associated with the manuscript **Spitting spiders (Araneae: Scytodidae) in Colombia and Venezuela: new records and natural history notes**.

## Scope

This package documents the exploratory climatic suitability analysis accompanying the manuscript, with occurrence provenance, model settings, evaluation tables and cartographic outputs.

## Occurrence data

The analysis combines **13 new localities reported in the manuscript** (7 Colombia, 6 Venezuela) with **4 unique Panamanian localities from GBIF**. The formal GBIF download contains 9 records: 8 georeferenced records representing 4 sites and 1 record without coordinates.

GBIF.org (2026). GBIF Occurrence Download. 4 October 2026. https://doi.org/10.15468/dl.p33n36

The combined dataset contained 17 unique coordinate localities. Wallace removed 3 localities sharing environmental cells, leaving 14 occupied cells. Venezuelan specimens follow the tentative taxonomic assignment documented in the manuscript.

## Model configuration

- Wallace, Maxent through maxnet, evaluation with ENMeval.
- WorldClim bioclimatic layers at 2.5 arc-minutes: BIO1, BIO12, BIO15.
- Calibration region: minimum convex polygon plus a 1-degree buffer.
- 10,000 random background points from 15,081 available terrestrial cells.
- Nonspatial leave-one-out validation: 14 folds.
- Features: L and LQ. Regularization multipliers: 0.5, 1, 1.5, 2, 3, 4 and 5 across the two runs.
- Clamping enabled; continuous cloglog output.

## Current findings

The retained **nonconstant** candidate is LQ with regularization multiplier 1.5: validation AUC 0.582 ± 0.152 (SD), training AUC 0.649, AICc 270.789, one nonzero coefficient, omission 0.143 at the 10th-percentile threshold and 0.071 at minimum training presence.

The evaluation also includes constant alternatives with AICc 269.393. The mapped candidate depicts spatial variation in exploratory climatic suitability and provides hypotheses for future field surveys; the evaluation tables document the model-selection context.

## Contents

- data/: formal GBIF download, source records and the combined occurrence table with provenance and review notes.
- results/: candidate-model evaluation tables and fold-level results.
- figures/: final map in PNG, PDF and TIFF, manuscript caption, and earlier working outputs.
- supplementary/: prediction raster, response curves, evaluation plots, masked environmental layers, background shapefile and Wallace session object.
- scripts/: R plotting helper and reproducible Python code for the final map, with dependency versions; these scripts do not refit the model.
- CITATION.cff: repository citation metadata.
- docs/: supporting documentation.

## Manuscript availability statement

Occurrence data, modelling documentation, evaluation tables and maps supporting this exploratory analysis are publicly available at https://github.com/ldelgado-png/Scytodes-SDM/tree/main/Scytodes_panamensis.

## Rights and provenance

GBIF records retain their source licences and attribution requirements. New occurrences are attributed to the manuscript and documented in the provenance tables.

## Final map

![Exploratory climatic suitability of Scytodes panamensis](figures/Scytodes_panamensis_map.png)

See [formats, caption and reproduction instructions](figures/README.md). The improved figure preserves the original model predictions and distinguishes GBIF localities from new manuscript records.

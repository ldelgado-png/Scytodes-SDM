# Scytodes panamensis SDM

Exploratory climatic suitability modelling associated with the manuscript **Spitting spiders (Araneae: Scytodidae) in Colombia and Venezuela: new records and natural history notes**.

## Status

Work in progress. This repository documents the current exploratory analysis; it is not yet a complete, independently reproduced workflow or an archived supplementary release. No repository DOI has been assigned.

## Occurrence data

The analysis combines **13 new localities reported in the manuscript** (7 Colombia, 6 Venezuela) with **4 unique Panamanian localities from GBIF**. The initial GBIF query contained 9 records: 8 georeferenced records at 4 sites and 1 record without coordinates. The formal download was checked against the initial identifiers and coordinates.

GBIF.org (2026). GBIF Occurrence Download. 4 October 2026. https://doi.org/10.15468/dl.p33n36

The combined dataset contained 17 unique coordinate localities. Wallace removed 3 records sharing environmental cells, leaving 14 occupied cells. Venezuelan specimens are tentatively assigned to the species in the manuscript. Taxonomic uncertainty must be retained in all interpretations.

## Model configuration

- Wallace, Maxent through maxnet, evaluation with ENMeval.
- WorldClim bioclimatic layers at 2.5 arc-minutes: BIO1, BIO12, BIO15.
- Calibration region: minimum convex polygon plus a 1-degree buffer.
- 10,000 random background points from 15,081 available cells.
- Nonspatial leave-one-out validation: 14 folds.
- Features: L and LQ. Initial regularization multipliers: 1, 2, 3, 4, 5; subsequent run: 0.5, 1, 1.5, 2 (14 unique combinations across runs).
- Clamping enabled; continuous cloglog output.

## Current findings

The retained **nonconstant** candidate is LQ with regularization multiplier 1.5: validation AUC 0.582 ± 0.152 (SD), training AUC 0.649, AICc 270.789, one nonzero coefficient, omission 0.143 at the 10th-percentile threshold and 0.071 at minimum training presence.

Constant alternatives had lower AICc (269.393). Thus, the retained model is not the overall AICc winner, and predictive discrimination is weak. The map is exploratory, not a validated range boundary, calibrated occurrence probability, or evidence of recent expansion. The GBIF DOI identifies source data, not the full modelling workflow.

## Contents

- `data/`: formal GBIF TSV and the original coordinate list supplied for the manuscript; voucher reconciliation remains pending.
- `results/`: original exported evaluation tables from both Wallace runs.
- `scripts/plot_prediction.R`: helper to plot an exported GeoTIFF; does not refit the model.
- `docs/PENDIENTES.md`: tasks required before a supplementary release.

## Manuscript availability statement

An evolving repository documenting the exploratory analysis is maintained at https://github.com/ldelgado-png/Scytodes-panamensis-SDM. A versioned, archived release and its DOI remain pending. This repository is currently private and must become accessible before it is cited as publicly available supplementary material.

## Rights and provenance

No blanket reuse licence has been assigned. GBIF records retain their source licences and attribution requirements. Confirm permissions and voucher provenance for newly reported occurrences before public release. The unpublished manuscript is not included.

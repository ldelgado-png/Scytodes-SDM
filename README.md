# Scytodes panamensis SDM

Reproducible exploratory climatic suitability modelling associated with the manuscript **Spitting spiders (Araneae: Scytodidae) in Colombia and Venezuela: new records and natural history notes**.

## Status

The analytical package is assembled for manuscript review and supplementary-material preparation. The model remains explicitly exploratory: the retained nonconstant candidate has moderate discrimination, constant models have lower AICc, and the available records are few, geographically clustered and partly tentative. A final public release still requires author review of vouchers, coordinates, permissions and archive DOI.

## Occurrence data

The analysis combines **13 new localities reported in the manuscript** (7 Colombia, 6 Venezuela) with **4 unique Panamanian localities from GBIF**. The formal GBIF download contains 9 records: 8 georeferenced records representing 4 sites and 1 record without coordinates.

GBIF.org (2026). GBIF Occurrence Download. 4 October 2026. https://doi.org/10.15468/dl.p33n36

The combined dataset contained 17 unique coordinate localities. Wallace removed 3 localities sharing environmental cells, leaving 14 occupied cells. Venezuelan specimens are tentatively assigned to the species in the manuscript; this uncertainty must remain explicit in interpretation.

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

Constant alternatives had lower AICc (269.393). Therefore, the retained model is not the overall AICc winner, and predictive discrimination is weak. The map is a survey-prioritization hypothesis, not a validated range boundary, calibrated occurrence probability, occupancy estimate, corridor, or evidence of recent expansion.

## Contents

- data/: formal GBIF download, source records and the combined occurrence table with provenance and review notes.
- results/: candidate-model evaluation tables and fold-level results.
- figures/: working visualization outputs.
- supplementary/: prediction raster, response curves, evaluation plots, masked environmental layers, background shapefile and Wallace session object.
- scripts/: plotting helper; it does not refit the model.
- CITATION.cff: repository citation metadata.
- docs/PENDIENTES.md: final publication and release checks.

## Manuscript availability statement

An evolving repository documenting the exploratory analysis is maintained at https://github.com/ldelgado-png/Scytodes-panamensis-SDM. Before publication, the authors should create a stable public release, archive that release in a repository that assigns a DOI, and replace the placeholders in the manuscript with the exact release tag, DOI and citation.

## Rights and provenance

GBIF records retain their source licences and attribution requirements. Newly reported occurrences require confirmation of voucher provenance, coordinate uncertainty, taxonomic review and permission for public redistribution before the repository is made public. The unpublished manuscript is not included.
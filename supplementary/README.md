# Supplementary analytical materials

This directory contains the files needed to inspect the exploratory climatic suitability analysis independently of the manuscript:

- the Wallace session object;
- the selected cloglog prediction raster;
- candidate-model evaluation tables and fold-level results;
- response curves and evaluation plots;
- masked environmental layers and the background shapefile used by the session.

The selected candidate was `fc.LQ_rm.1.5`. It was retained among nonconstant candidates because it combined the highest mean validation AUC with the lowest AICc in that subset. Constant models had lower AICc overall, and the validation AUC was moderate with substantial fold variation. Therefore, the raster must be presented as an exploratory survey-prioritization surface, not as an estimate of occupancy, a validated range boundary, or evidence of recent expansion.

The files are versioned outputs from the 4 October 2026 analysis. Any publication release should also include a complete `sessionInfo()` capture from the execution environment and a public archive DOI.
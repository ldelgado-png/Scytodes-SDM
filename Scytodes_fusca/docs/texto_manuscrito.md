# Integración de Scytodes fusca

Análisis exploratorio conservado; no se excluyó retrospectivamente el registro inconsistente.

## Resumen / Abstract

Ubicación: Añadir al final del componente de modelado del resumen; no reemplazar los resultados taxonómicos.

Exploratory modelling of Scytodes fusca using global GBIF occurrences and new records reported here showed weak spatial validation and substantial sensitivity to model configuration; its projections for Colombia and Venezuela were therefore retained as supplementary exploratory outputs.

## Métodos / Methods

Ubicación: Añadir una subsección sobre S. fusca después de los métodos de S. longipes, bajo Exploratory climatic suitability modelling.

For Scytodes fusca, a snapshot of 1,479 georeferenced GBIF API records was combined with 20 manuscript records representing 17 unique coordinate pairs. Coordinate-range, duplicate, fossil and uncertainty filters were applied; records with reported uncertainty exceeding 5 km were excluded, whereas those lacking uncertainty estimates were retained. One occurrence per climatic cell and a minimum spacing of 10 km were imposed, prioritizing manuscript records. The resulting exploratory dataset comprised 586 occurrences (569 labelled GBIF and 17 labelled manuscript). These filters did not ensure complete geographic validity.

## Métodos: configuración

Ubicación: Continuar la misma subsección.

Models were fitted in R using maxnet 0.1.4 and ENMeval 2.0.5, with WorldClim 2.1 predictors BIO1, BIO4, BIO12 and BIO15 at 2.5 arc-minute resolution. The calibration background was defined by the union of 111-km geodesic buffers around retained global occurrences, from which 10,000 background points were sampled. Absolute pairwise correlations among predictors did not exceed 0.609. Four spatial blocks contained 147, 146, 147 and 146 occurrences, respectively, and validation used background points from the corresponding held-out block. Forty configurations combined L, LQ, H and LQH features with regularization multipliers from 0.5 to 5 in increments of 0.5. Models were evaluated from tabular environmental values; consequently, AICc was calculated using background data. Projections used clamping and cloglog output and were restricted to Colombia and Venezuela.

## Métodos: selección y comparación

Ubicación: Continuar antes del cierre de la subsección.

No configuration met the initial criterion of mean omission at the tenth-percentile training threshold ≤0.10. The provisional model was therefore chosen by minimum omission, with AICc as a tie-breaker. The minimum-AICc configuration was retained as an alternative. Their regional projections were compared across cells with finite values in both rasters using Pearson and Spearman correlations, mean signed and absolute differences, and root mean square difference. These cell-based summaries were not weighted by cell area and quantify agreement between predictions rather than predictive accuracy. A post-fit audit identified GBIF occurrence 1291613600 as geographically inconsistent: it was attributed to Western Cape, South Africa, but its coordinates (96.37°E, 83.02°S) placed it in Antarctica. The archived analysis retains this occurrence without refitting, and its influence was not quantified.

## Resultados / Results

Ubicación: Añadir después de los resultados de S. longipes, en el apartado de modelado.

The provisional LQ model with regularization multiplier 4.5 had mean validation AUC 0.535 ± 0.067 SD and mean tenth-percentile omission 0.114. The alternative LQH model with multiplier 1 had the lowest AICc (10,680.853), validation AUC 0.597 ± 0.046 and omission 0.156; the provisional model had ΔAICc = 143.141. Across 97,465 shared projection cells, Pearson correlation was 0.357 and Spearman correlation was 0.327. Mean absolute difference was 0.164, root mean square difference was 0.201, and the mean signed difference (LQH minus LQ) was −0.156. The largest visible reductions under LQH occurred in Andean sectors and southern Colombia. Block 4 contained 28 of the 30 retained occurrences from Colombia and Venezuela, as well as occurrences from other countries; the LQH model had AUC 0.536 and omission 0.295 in that block. This is not an evaluation restricted exclusively to the two projection countries.

## Discusión / Discussion

Ubicación: Añadir inmediatamente después del párrafo que interpreta las limitaciones de los modelos de panamensis y longipes.

The Scytodes fusca projections were sensitive to feature complexity and regularization, and neither configuration provided strong spatial discrimination. Lower omission in the simpler LQ model coincided with a comparatively uniform projection, whereas the minimum-AICc LQH model produced greater spatial contrast and higher omission. The low agreement between their projections cautions against interpreting either map as a robust range estimate or as calibrated occurrence probability. Uneven geographic representation, the worldwide calibration design and the retained coordinate inconsistency further limit interpretation; their individual effects were not tested. We therefore retain these outputs as supplementary exploratory analyses, without inferring range expansion, dispersal corridors or absence from low-scoring areas.

## Disponibilidad de datos / Data availability

Ubicación: Añadir al apartado de disponibilidad, sustituyendo únicamente la URL antigua del repositorio cuando corresponda.

Occurrence inputs, analysis scripts, available evaluation tables, figures and the raster of differences for the exploratory Scytodes analyses are organized by species at https://github.com/ldelgado-png/Scytodes-SDM. The Scytodes fusca material is available in the Scytodes_fusca directory. The GBIF download DOI supplied for this species is https://doi.org/10.15468/dl.m67db8; the analysis used the archived API snapshot, and equivalence with the formal DOI download has not yet been verified. The two original prediction GeoTIFFs and fitted model objects are not included in the current archive.

## Bibliografía / Reference

Ubicación: Añadir a References junto con las otras descargas GBIF; confirmar metadatos del DOI antes de envío.

GBIF.org. (2026). GBIF Occurrence Download [Data set]. https://doi.org/10.15468/dl.m67db8

## Leyenda: mapa alternativo

Ubicación: Material complementario: asignar el número definitivo al maquetar.

Supplementary Figure [number]. Exploratory climatic suitability of Scytodes fusca in Colombia and Venezuela under the minimum-AICc LQH configuration (regularization multiplier 1), calibrated with global occurrences. Colours represent cloglog model output; white circles show retained GBIF occurrences, orange triangles new Colombian records and yellow diamonds new Venezuelan records. Mean spatial validation AUC was 0.597 ± 0.046 SD. The archived calibration dataset includes a geographically inconsistent occurrence identified after fitting.

## Leyenda: comparación

Ubicación: Material complementario: asignar el número definitivo al maquetar.

Supplementary Figure [number]. Sensitivity of Scytodes fusca projections to model configuration: LQ with multiplier 4.5 (left), LQH with multiplier 1 (centre), and LQH minus LQ (right). Prediction panels share a 0–1 scale; positive differences are red and negative differences blue. Agreement across 97,465 shared cells was limited (Pearson r = 0.357; Spearman ρ = 0.327). Differences describe sensitivity to configuration and do not identify the more accurate prediction.

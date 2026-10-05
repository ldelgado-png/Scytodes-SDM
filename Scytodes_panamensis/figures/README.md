# Figures

## Final map — 4 October 2026

![Scytodes panamensis exploratory climatic suitability](Scytodes_panamensis_map.png)

- [PNG](Scytodes_panamensis_map.png), [PDF](Scytodes_panamensis_map.pdf) and [TIFF](Scytodes_panamensis_map.tif). Raster figure exports: 400 dpi.
- [Manuscript caption](Scytodes_panamensis_map_caption.txt).
- [Python plotting code](../scripts/plot_final_map.py) and [tested dependency versions](../scripts/requirements-map.txt).

Country boundaries and names, coordinates, north arrow and a 200 km scale bar were added. White circles show GBIF localities in Panama, orange triangles new Colombian records, and yellow diamonds tentatively identified Venezuelan records. Nearby points overlap. The 17 coordinate localities shown correspond to 14 occupied environmental cells used by the model.

The underlying prediction is unchanged (LQ, RM 1.5). Its cloglog range is 0.5758–0.8010; the colour scale spans 0.57–0.81. Grey land denotes no prediction, not unsuitable habitat. This remains an exploratory result; constant candidates had lower AICc overall.

## Reproduce from the repository root

```bash
python -m pip install -r scripts/requirements-map.txt
python scripts/plot_final_map.py
```

The script reads `data/occurrences_combined.csv` and `supplementary/Scytodes_panamensis_fc.LQ_rm.1.5_cloglog.tif`, and writes the three map formats under `figures/`. It requires Internet access on first use to download Natural Earth 1:50m country boundaries via Cartopy; subsequent runs use Cartopy's cache. The script visualizes the exported raster and does not refit the model.

## Earlier working figures

The original `prediction_map.jpg`, `prediction_map_occurrences.jpg` and `suitability_histogram.jpg` are retained as working outputs. Use `Scytodes_panamensis_map.*` for the improved map.

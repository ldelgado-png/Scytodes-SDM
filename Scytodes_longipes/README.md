# Scytodes longipes: modelo de distribución potencial

Repositorio reproducible para el análisis exploratorio de distribución potencial de *Scytodes longipes* en Colombia y Venezuela. El modelo se calibró con ocurrencias combinadas de registros nuevos y GBIF, y se proyectó sobre Colombia y Venezuela usando variables bioclimáticas de WorldClim.

## Datos de ocurrencia

Los datos de GBIF se obtuvieron mediante una descarga formal con el siguiente DOI:

**GBIF.org (2026). GBIF Occurrence Download.** https://doi.org/10.15468/dl.r7a77w

La descarga debe citarse junto con la fecha de consulta indicada por GBIF. Los registros nuevos aportados en el manuscrito se mantienen identificados como datos propios en los archivos de procedencia.

## Flujo de modelado

- Algoritmo: Maxent mediante `maxnet` y `ENMeval`.
- Variables: BIO1, BIO4, BIO12 y BIO15 de WorldClim v2.1, resolución de 2.5 minutos de arco.
- Ocurrencias retenidas: 121 localidades después de la revisión y reducción espacial.
- Fondo: 10.000 puntos de fondo.
- Partición: cuatro bloques espaciales con `ENMeval::get.block()`.
- Combinaciones evaluadas: FC = L, LQ, H y LQH; RM = 0.5–5.0 en intervalos de 0.5.
- Proyección: Colombia y Venezuela.

## Resultados

El mapa exploratorio corresponde a LQH, RM 0.5, seleccionado por la menor omisión al percentil 10. Su AUC media de validación fue 0.547 ± 0.091. La evaluación incluye también LQH, RM 2.0, con el menor AICc y AUC de validación 0.463, y H, RM 0.5, con AUC de validación 0.553 ± 0.089. Las tablas permiten examinar los criterios de selección y el desempeño de cada configuración.

La proyección representa idoneidad climática exploratoria y complementa los registros de distribución e historia natural del manuscrito.

## Reproducción

1. Abrir `scripts/modelar_longipes.R` en RStudio.
2. Seleccionar la carpeta `Scytodes_longipes/` cuando el script solicite el directorio del proyecto.
3. Ejecutar el script por secciones.
4. El script descarga WorldClim, extrae los valores ambientales, evalúa 40 configuraciones, selecciona un modelo y genera el raster y el mapa final.

## Estructura

- `scripts/`: código reproducible en R.
- `datos/`: ocurrencias, particiones y procedencia.
- `resultados/`: tablas de evaluación y predicciones generadas al ejecutar el script.
- `figuras/`: vista previa del mapa exploratorio. El script genera PNG, PDF y TIFF en `mapas/`.

## Cita del repositorio

Delgado-Santa, L. 2026. *Scytodes longipes: modelo de distribución potencial en Colombia y Venezuela*. Repositorio de análisis reproducible. GitHub. https://github.com/ldelgado-png/Scytodes-SDM/tree/main/Scytodes_longipes

## Licencias y procedencia

Los registros de GBIF conservan las licencias y atribuciones de sus conjuntos de datos originales. Los registros nuevos deben citarse de acuerdo con el manuscrito y la información de sus vouchers. El DOI de GBIF identifica la descarga de ocurrencias; el repositorio documenta el procesamiento y modelado.

## Vista previa del mapa

![Mapa exploratorio de Scytodes longipes](figuras/Scytodes_longipes_map_preview.png)

La vista previa incluida mide 663 × 597 píxeles y documenta la salida cartográfica del análisis.

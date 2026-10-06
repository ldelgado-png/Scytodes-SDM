# Scytodes fusca: idoneidad climática exploratoria

Materiales complementarios del manuscrito sobre *Scytodes* de Colombia y Venezuela. El análisis combina registros globales de GBIF con nuevos registros aportados por el manuscrito y proyecta la idoneidad climática sobre Colombia y Venezuela.

Referencia de descarga GBIF: [10.15468/dl.m67db8](https://doi.org/10.15468/dl.m67db8). La instantánea API utilizada en el ajuste y sus metadatos se conservan en `datos/`.

## Datos y métodos

El conjunto inicial integra 1.479 registros georreferenciados de la API y 20 filas del subconjunto del manuscrito, correspondientes a 17 coordenadas únicas. El análisis retuvo 586 presencias: 569 etiquetadas como GBIF y 17 como registros del manuscrito.

- Predictores: BIO1, BIO4, BIO12 y BIO15 de WorldClim 2.1, a 2.5 minutos de arco.
- Reducción espacial: una presencia por celda ambiental y separación mínima de 10 km.
- Región de calibración: unión de buffers geodésicos de 111 km alrededor de las presencias globales.
- Fondo: 10.000 puntos.
- Validación: cuatro bloques espaciales, con 147, 146, 147 y 146 presencias.
- Algoritmo: Maxent mediante `maxnet`, evaluado con `ENMeval`.
- Configuraciones: 40 combinaciones de clases de características y regularización.
- Proyección: Colombia y Venezuela, con clamping y salida cloglog.

## Resultados

Se documentan dos configuraciones complementarias: LQ, RM 4.5, seleccionada por menor omisión, y LQH, RM 1, seleccionada como alternativa por menor AICc.

| Configuración | Criterio | AUC validación ± DE | Omisión 10p | ΔAICc |
|---|---|---|---|---|
| LQ, RM 4.5 | Menor omisión | 0.535 ± 0.067 | 0.114 | 143.141 |
| LQH, RM 1 | Menor AICc | 0.597 ± 0.046 | 0.156 | 0 |

La [documentación técnica](docs/LIMITACIONES.md) describe la auditoría de coordenadas, las condiciones de interpretación y el contenido de la versión archivada.

## Mapas y comparación

![Idoneidad climática exploratoria: LQH RM1](mapas/Scytodes_fusca_block_LQH_rm1.png)

![Comparación de configuraciones](mapas/comparacion_Scytodes_fusca.png)

La comparación comprende 97.465 celdas compartidas: Pearson = 0.357; Spearman = 0.327; diferencia absoluta media = 0.164; RMSE entre predicciones = 0.201. Estas métricas caracterizan la concordancia entre configuraciones.

## Materiales disponibles

- `datos/`: instantánea de GBIF, respuestas originales comprimidas, metadatos y registros del manuscrito.
- `scripts/`: preparación de datos, clima y fondo, ajuste de modelos, proyección, alternativa y comparación.
- `resultados/block/`: evaluación de 40 configuraciones, diagnósticos por bloque, presencias, grupos, concordancia y GeoTIFF de diferencias.
- `mapas/`: mapa alternativo, comparación y captura del mapa inicial.
- `docs/`: documentación técnica y texto de integración al manuscrito.

## Reproducción

1. Abrir RStudio y seleccionar la carpeta `Scytodes_fusca/` como proyecto de trabajo.
2. Ejecutar `scripts/01_datos.R` y `scripts/02_clima_fondo.R`.
3. Ejecutar `scripts/03_modelos.R` y `scripts/04_proyeccion_mapa.R`.
4. Ejecutar `scripts/05_alternativa_LQH.R` y `scripts/06_comparacion.R` para generar la alternativa y el contraste entre predicciones.

El muestreo de fondo utiliza `exhaustive=TRUE`, `values=TRUE` y una comprobación de 10.000 puntos. Los scripts producen las tablas y salidas cartográficas en las carpetas correspondientes.

## Citas y procedencia

GBIF.org (2026). GBIF Occurrence Download. https://doi.org/10.15468/dl.m67db8

Repositorio: https://github.com/ldelgado-png/Scytodes-SDM

La [ficha de procedencia GBIF](datos/GBIF_DOI.md) documenta la referencia de descarga y la instantánea analizada. Los registros de GBIF mantienen las licencias y atribuciones de sus conjuntos fuente; los registros nuevos corresponden al manuscrito.

# Estado conservado del análisis

Por decisión del autor, se conserva la corrida inicial sin volver a ajustar los modelos ni excluir registros retrospectivamente. Ningún resultado se presenta como validación definitiva.

## Inconsistencia de coordenadas detectada después del ajuste
GBIF 1291613600 (GBIF_1291613600): país ZA; localidad administrativa Western Cape; longitud 96.37; latitud -83.02; país espacial AQ. El registro permanece entre las 586 presencias, en el bloque 2, y pudo afectar el fondo y el ajuste. No se ha corregido ni medido su efecto. El filtro de la corrida no garantiza concordancia país–coordenadas.

## Validación y sensibilidad
Ninguna configuración cumple omisión media al percentil 10 <=0.10. LQ/RM4.5 fue seleccionada por menor omisión, no por menor AICc. LQH/RM1 se conserva como alternativa de menor AICc. La concordancia regional es limitada (Pearson 0.357; Spearman 0.327; diferencia absoluta media 0.164). El bloque 4 incluye 28 de las 30 presencias CO/VE, pero también otros países: sus métricas no son una validación exclusiva de Colombia y Venezuela.

La comparación entre dos configuraciones es sensibilidad a la selección del modelo. No es un análisis completo de incertidumbre, ni sensibilidad al fondo, a la depuración o a variables. No se aplicó una superficie de esfuerzo ni target-group background.

## Archivos no recibidos
No se recibieron los dos GeoTIFF originales de predicción, los modelos RDS, fondo_clima.csv, la región GPKG, evaluacion_por_grupo.csv completa, sessionInfo.txt ni PDF/TIFF originales de figuras. El GeoTIFF disponible es únicamente la diferencia entre predicciones. La imagen LQ/RM4.5 es una captura; LQH/RM1 y la comparación son PNG recibidos. No se han recreado los faltantes ni vuelto a correr los modelos en este entorno.

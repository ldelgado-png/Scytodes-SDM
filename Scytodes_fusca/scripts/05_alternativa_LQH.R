# Ejecutar después de 01-04, en la misma sesión. Conserva el mapa inicial.
tabla <- read.csv(file.path(salida, "evaluacion_40_modelos.csv"))
modelos <- readRDS(file.path(salida, "modelos_maxnet.rds"))
indice <- which(tabla$fc == "LQH" & tabla$rm == 1)
stopifnot(length(indice)==1, length(modelos)==nrow(tabla))
alternativa <- new.env(parent=globalenv())
alternativa$modelo <- modelos[[indice]]
alternativa$elegido <- tabla[indice,,drop=FALSE]
alternativa$METODO <- paste0(METODO,"_LQH_rm1")
alternativa$salida <- file.path(salida,"alternativa_LQH_rm1")
dir.create(alternativa$salida,recursive=TRUE,showWarnings=FALSE)
saveRDS(alternativa$modelo,file.path(alternativa$salida,"modelo_seleccionado.rds"))
write.csv(alternativa$elegido,file.path(alternativa$salida,"modelo_alternativo.csv"),row.names=FALSE)
source("scripts/04_proyeccion_mapa.R",local=alternativa,encoding="UTF-8")

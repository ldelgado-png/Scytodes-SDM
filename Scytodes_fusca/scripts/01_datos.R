# 1. Ejecutar en una sesion NUEVA de RStudio, sin restaurar .RData.
# Seleccionar la carpeta Scytodes_fusca descomprimida.
proyecto <- if (.Platform$OS.type == "windows") choose.dir(caption="Seleccione Scytodes_fusca") else readline("Ruta de Scytodes_fusca: ")
stopifnot(length(proyecto)==1, !is.na(proyecto), dir.exists(proyecto))
setwd(proyecto)
stopifnot(file.exists("datos/manuscrito.csv"), file.exists("datos/gbif_original.csv"))
paquetes <- c("terra","sf","geodata","ENMeval","maxnet","ggplot2","rnaturalearth","rnaturalearthdata","ggspatial")
faltan <- setdiff(paquetes, rownames(installed.packages()))
if(length(faltan)) install.packages(faltan, repos="https://cloud.r-project.org")
ok_paquetes <- vapply(paquetes, requireNamespace, logical(1), quietly=TRUE)
if(!all(ok_paquetes)) stop("No cargan: ", paste(paquetes[!ok_paquetes],collapse=", "))
for(d in c("clima","temporal","resultados","mapas")) dir.create(d,showWarnings=FALSE)
terra::terraOptions(tempdir=normalizePath("temporal"),memfrac=0.25,progress=1)
SEED <- 20261006L
set.seed(SEED)
METODO <- "block"
salida <- file.path("resultados",METODO);dir.create(salida,showWarnings=FALSE)
variables <- c("bio01","bio04","bio12","bio15")
xy <- c("longitude","latitude")
# Umbrales exploratorios iguales a la depuracion de longipes.
INCERTIDUMBRE_MAX_M <- 5000
DISTANCIA_MIN_KM <- 10
# Buffer geodesico de 111 km, aproximacion explicita a 1 grado de latitud.
# No es identico a un buffer angular de 1 grado en todas las latitudes.
BUFFER_M <- 111000
N_FONDO <- 10000L
m <- read.csv("datos/manuscrito.csv", stringsAsFactors=FALSE)
g <- read.csv("datos/gbif_original.csv", stringsAsFactors=FALSE)
manuscrito <- data.frame(record_id=m$record_id,longitude=m$longitude,latitude=m$latitude,source="Manuscript",countryCode=NA_character_,stateProvince=m$stateProvince_original,uncertainty=NA_real_,geospatial_issue=FALSE,basisOfRecord="Manuscript record",gbifID=NA_character_)
gbif <- data.frame(record_id=paste0("GBIF_",g$key),longitude=g$decimalLongitude,latitude=g$decimalLatitude,source="GBIF",countryCode=g$countryCode,stateProvince=g$stateProvince,uncertainty=g$coordinateUncertaintyInMeters,geospatial_issue=toupper(as.character(g$hasGeospatialIssues))=="TRUE",basisOfRecord=g$basisOfRecord,gbifID=as.character(g$key))
datos <- rbind(manuscrito,gbif)
datos$longitude <- as.numeric(datos$longitude);datos$latitude <- as.numeric(datos$latitude)
datos$uncertainty <- as.numeric(datos$uncertainty)
datos$reason <- "eligible"
marcar <- function(z,motivo) {z[is.na(z)] <- FALSE; datos$reason[z & datos$reason=="eligible"] <<- motivo}
marcar(!is.finite(datos$longitude)|!is.finite(datos$latitude)|abs(datos$longitude)>180|abs(datos$latitude)>90,"invalid_coordinates")
marcar(datos$longitude==0 & datos$latitude==0,"zero_zero")
marcar(datos$basisOfRecord=="FOSSIL_SPECIMEN","fossil")
marcar(datos$geospatial_issue,"GBIF_geospatial_issue")
marcar(!is.na(datos$uncertainty)&datos$uncertainty>INCERTIDUMBRE_MAX_M,"uncertainty_over_5km")
# Las coordenadas repetidas conservan una sola presencia; prioridad manuscrito.
llave <- paste(format(datos$longitude,digits=12),format(datos$latitude,digits=12),sep="|")
id_elegibles <- which(datos$reason=="eligible")
datos$supporting_records <- NA_character_;datos$shared_sources <- NA_character_
for(k in unique(llave[id_elegibles])) {
 z <- id_elegibles[llave[id_elegibles]==k]
 datos$supporting_records[z] <- paste(datos$record_id[z],collapse=";")
 datos$shared_sources[z] <- paste(unique(datos$source[z]),collapse=";")
 if(length(z)>1) datos$reason[z[-1]] <- "duplicate_coordinates"
}
occs <- datos[datos$reason=="eligible",,drop=FALSE]
write.csv(datos,file.path(salida,"auditoria_coordenadas.csv"),row.names=FALSE,na="")
write.csv(occs,file.path(salida,"coordenadas_unicas.csv"),row.names=FALSE,na="")
cat("Registros manuscrito:",nrow(manuscrito),"; coordenadas unicas:",nrow(unique(manuscrito[,xy])),"\n")
cat("Registros GBIF georreferenciados:",nrow(gbif),"\n")
print(table(datos$reason));cat("Presencias candidatas:",nrow(occs),"\n")
# S_fusca en la fila MS_001 no es un estado: se conserva como etiqueta original.
# Todos los paises del manuscrito se verifican por interseccion en el paso 2.

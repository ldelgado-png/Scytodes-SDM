# 2. Clima y fondo global. Puede tardar durante la primera descarga.
# 3. CLIMA EN DISCO: SIN RESTAURAR PUNTEROS DE UN RDS -----------------------
archivos <- file.path("clima", paste0(variables, ".tif"))
if (!all(file.exists(archivos))) {
  wc <- geodata::worldclim_global(var = "bio", res = 2.5, path = "clima")
  nums <- as.integer(sub(".*_", "", names(wc)))
  stopifnot(all(c(1, 4, 12, 15) %in% nums))
  for (i in seq_along(variables)) {
    r <- wc[[which(nums == c(1, 4, 12, 15)[i])]]
    names(r) <- variables[i]
    terra::writeRaster(r, archivos[i], overwrite = TRUE)
  }
  rm(wc, r); gc()
}
clima <- terra::rast(archivos)
names(clima) <- variables
stopifnot(terra::is.lonlat(clima))
# Coordenadas originales asumidas WGS84; transformar de forma explicita al CRS raster.
extraer <- function(tabla) {
  puntos <- terra::vect(tabla[, xy], geom = xy, crs = "EPSG:4326")
  puntos <- terra::project(puntos, terra::crs(clima))
  terra::extract(clima, puntos, ID = FALSE)
}

set.seed(SEED)
paises_file <- "datos/naturalearth_50m.rds"
if(!file.exists(paises_file)) saveRDS(rnaturalearth::ne_countries(scale="medium",returnclass="sf"),paises_file)
paises <- sf::st_make_valid(readRDS(paises_file))
pts <- sf::st_as_sf(occs,coords=xy,crs=4326,remove=FALSE)
hits <- sf::st_intersects(pts,paises)
pais_geometria <- vapply(hits,function(z) if(length(z)==1) as.character(paises$iso_a2[z]) else NA_character_,character(1))
# Coordenadas sin pais/puntos costeros ambiguos quedan auditados; no se excluyen
# automaticamente por la simplificacion cartografica de Natural Earth.
idx <- occs$source=="Manuscript"
occs$countryCode[idx] <- pais_geometria[idx]
occs$country_spatial <- pais_geometria
write.csv(occs,file.path(salida,"paises_y_coordenadas.csv"),row.names=FALSE,na="")
oenv <- extraer(occs)
clima_ok <- complete.cases(oenv)
datos$reason[match(occs$record_id[!clima_ok],datos$record_id)] <- "missing_climate"
occs <- occs[clima_ok,,drop=FALSE];oenv <- oenv[clima_ok,,drop=FALSE]
# Una presencia por celda ambiental.
celda <- terra::cellFromXY(clima,as.matrix(occs[,xy]))
u <- !duplicated(celda)
datos$reason[match(occs$record_id[!u],datos$record_id)] <- "duplicate_climate_cell"
occs <- occs[u,,drop=FALSE];oenv <- oenv[u,,drop=FALSE]
# Thinning reproducible: prioridad manuscrito, luego menor incertidumbre.
orden <- order(occs$source!="Manuscript",ifelse(is.na(occs$uncertainty),Inf,occs$uncertainty),occs$record_id)
occs <- occs[orden,,drop=FALSE];oenv <- oenv[orden,,drop=FALSE]
haversine <- function(lon,lat,lons,lats) {
 a <- (sin((lats-lat)*pi/360))^2 + cos(lat*pi/180)*cos(lats*pi/180)*(sin((lons-lon)*pi/360))^2
 6371.0088*2*asin(pmin(1,sqrt(pmax(0,a))))
}
retenidos <- integer(0)
for(i in seq_len(nrow(occs))) {
 if(!length(retenidos) || all(haversine(occs$longitude[i],occs$latitude[i],occs$longitude[retenidos],occs$latitude[retenidos])>=DISTANCIA_MIN_KM)) retenidos <- c(retenidos,i)
}
excluidos <- setdiff(seq_len(nrow(occs)),retenidos)
datos$reason[match(occs$record_id[excluidos],datos$record_id)] <- "thinning_10km"
occs <- occs[retenidos,,drop=FALSE];oenv <- oenv[retenidos,,drop=FALSE]
datos$reason[match(occs$record_id,datos$record_id)] <- "retained"
write.csv(datos,file.path(salida,"auditoria_final.csv"),row.names=FALSE,na="")
stopifnot(nrow(occs)>=20,all(complete.cases(oenv)))
# Se delimita el fondo alrededor de TODAS las presencias globales retenidas.
puntos <- terra::vect(occs[,xy],geom=xy,crs="EPSG:4326")
buffer <- terra::aggregate(terra::buffer(puntos,width=BUFFER_M))
terra::writeVector(buffer,file.path(salida,"region_calibracion.gpkg"),overwrite=TRUE)
base <- terra::crop(clima[[1]],buffer,filename=file.path(salida,"bio1_recorte_global.tif"),overwrite=TRUE)
mascara <- terra::mask(base,buffer,filename=file.path(salida,"mascara_fondo.tif"),overwrite=TRUE)
# Muestreo de celdas, sin construir un data.frame del clima mundial.
pbg <- terra::spatSample(mascara,size=N_FONDO,method="random",na.rm=TRUE,exhaustive=TRUE,as.points=TRUE,values=TRUE)
bg <- as.data.frame(terra::crds(pbg));names(bg) <- xy
benv <- extraer(bg)
bg <- bg[complete.cases(benv),,drop=FALSE];benv <- benv[complete.cases(benv),,drop=FALSE]
if(nrow(bg)<N_FONDO) warning("Fondo valido menor al solicitado: ",nrow(bg))
stopifnot(nrow(bg)==N_FONDO,all(vapply(benv,sd,numeric(1))>0))
write.csv(cbind(occs,oenv),file.path(salida,"presencias_clima.csv"),row.names=FALSE,na="")
write.csv(cbind(bg,benv),file.path(salida,"fondo_clima.csv"),row.names=FALSE)
correlacion <- cor(benv)
write.csv(correlacion,file.path(salida,"correlacion_fondo.csv"));print(round(correlacion,3))
if(any(abs(correlacion[upper.tri(correlacion)])>=0.7)) warning("|r| >= 0.7 entre predictores. Corrida exploratoria; revisar variables antes del analisis definitivo.")
cat("Presencias globales retenidas:",nrow(occs),"; fondo:",nrow(bg),"\n")
print(table(occs$countryCode,useNA="ifany"))

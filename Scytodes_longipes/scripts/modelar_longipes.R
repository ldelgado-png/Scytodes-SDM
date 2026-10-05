# Scytodes longipes: calibracion mundial, proyeccion Colombia y Venezuela.
# Datos GBIF: GBIF Occurrence Download, DOI 10.15468/dl.r7a77w.
# Abrir este script en RStudio y ejecutar por secciones. No requiere Wallace.
# Seleccionar la carpeta Scytodes_longipes cuando se solicite.

# 1. CARPETA Y PAQUETES ----------------------------------------------------
proyecto <- if (.Platform$OS.type == "windows") choose.dir(caption = "Seleccione Scytodes_longipes") else readline("Ruta de Scytodes_longipes: ")
stopifnot(length(proyecto) == 1, !is.na(proyecto), dir.exists(proyecto))
setwd(proyecto)
stopifnot(file.exists("datos/particiones_wallace.csv"))
paquetes <- c("terra", "sf", "geodata", "ENMeval", "maxnet", "ggplot2", "rnaturalearth", "rnaturalearthdata", "ggspatial")
faltan <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltan)) install.packages(faltan, repos = "https://cloud.r-project.org")
invisible(lapply(paquetes, requireNamespace, quietly = TRUE))
for (d in c("clima", "temporal", "resultados", "mapas")) dir.create(d, showWarnings = FALSE)
terra::terraOptions(tempdir = normalizePath("temporal"), memfrac = 0.25, progress = 1)
set.seed(20261004)
# Cambiar a "checkerboard" para repetir la particion previa de Wallace.
METODO <- "block"
stopifnot(METODO %in% c("block", "checkerboard"))
salida <- file.path("resultados", METODO)
dir.create(salida, showWarnings = FALSE)
variables <- c("bio01", "bio04", "bio12", "bio15")

# 2. DATOS YA DEPURADOS ----------------------------------------------------
datos <- read.csv("datos/particiones_wallace.csv", check.names = FALSE)
occs <- subset(datos, scientific_name == "Scytodes longipes")
bg <- subset(datos, scientific_name == "background")
xy <- c("longitude", "latitude")
stopifnot(nrow(occs) == 121, nrow(bg) == 10000,
          all(complete.cases(datos[, c(xy, "group")])),
          all(abs(datos$longitude) <= 180), all(abs(datos$latitude) <= 90))
# Estos puntos de fondo proceden del muestreo exitoso con buffers de 1 grado.
# No se vuelven a generar para conservar exactamente el conjunto exportado.

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
oenv <- extraer(occs)
benv <- extraer(bg)
if (any(!complete.cases(oenv)) || any(!complete.cases(benv))) {
  write.csv(occs[!complete.cases(oenv), ], file.path(salida, "presencias_sin_clima.csv"), row.names = FALSE)
  write.csv(bg[!complete.cases(benv), ], file.path(salida, "fondo_sin_clima.csv"), row.names = FALSE)
  stop("Hay puntos sin valores climaticos. Revisar los CSV antes de continuar.")
}
celda_o <- terra::cellFromXY(clima, as.matrix(occs[, xy]))
stopifnot(!anyDuplicated(celda_o))
stopifnot(all(vapply(benv, sd, numeric(1)) > 0))
write.csv(cbind(occs, oenv), file.path(salida, "presencias_clima.csv"), row.names = FALSE)
write.csv(cbind(bg, benv), file.path(salida, "fondo_clima.csv"), row.names = FALSE)
correlacion <- cor(benv, method = "pearson")
write.csv(correlacion, file.path(salida, "correlacion_fondo.csv"))
print(round(correlacion, 3))
if (any(abs(correlacion[upper.tri(correlacion)]) >= 0.7))
  warning("Hay pares con |r| >= 0.7. Se conservan las cuatro variables en esta corrida exploratoria; revisar antes de la version final.")

# 4. PARTICIONES Y EVALUACION SIN RASTERES ---------------------------------
if (METODO == "block") {
  grupos <- ENMeval::get.block(occs[, xy], bg[, xy], orientation = "lat_lon")
} else {
  grupos <- list(occs.grp = occs$group, bg.grp = bg$group)
}
conteos <- merge(as.data.frame(table(grupos$occs.grp)), as.data.frame(table(grupos$bg.grp)), by = "Var1")
names(conteos) <- c("grupo", "presencias", "fondo")
print(conteos)
stopifnot(all(conteos$presencias >= 5), all(conteos$fondo >= 20))
write.csv(conteos, file.path(salida, "tamano_grupos.csv"), row.names = FALSE)
write.csv(data.frame(occs[, xy], group = grupos$occs.grp), file.path(salida, "grupos_presencias.csv"), row.names = FALSE)
write.csv(data.frame(bg[, xy], group = grupos$bg.grp), file.path(salida, "grupos_fondo.csv"), row.names = FALSE)

# SWD: coordenadas + valores ambientales, envs=NULL. Evita convertir rasteres
# mundiales en data.frames y no depende de objetos espaciales serializados.
# AICc se aproxima con el fondo; no comparar directamente con AICc de Wallace
# calculado sobre todas las celdas. Se usa fondo de validacion de cada particion.
evaluacion <- ENMeval::ENMevaluate(
  occs = cbind(occs[, xy], oenv), bg = cbind(bg[, xy], benv),
  envs = NULL, algorithm = "maxnet", partitions = "user", user.grp = grupos,
  tune.args = list(fc = c("L", "LQ", "H", "LQH"), rm = seq(0.5, 5, 0.5)),
  doClamp = TRUE, raster.preds = FALSE, parallel = FALSE,
  other.settings = list(pred.type = "cloglog", validation.bg = "partition"))
tabla <- evaluacion@results
write.csv(tabla, file.path(salida, "evaluacion_40_modelos.csv"), row.names = FALSE)
write.csv(evaluacion@results.partitions, file.path(salida, "evaluacion_por_grupo.csv"), row.names = FALSE)
# Guardar modelos ordinarios y tablas; no guardar SpatRaster ni toda la sesion.
saveRDS(evaluacion@models, file.path(salida, "modelos_maxnet.rds"))
saveRDS(list(results = tabla, groups = grupos, variables = variables), file.path(salida, "evaluacion_tabular.rds"))
writeLines(capture.output(sessionInfo()), file.path(salida, "sessionInfo.txt"))

# 5. SELECCION PROVISIONAL -------------------------------------------------
# Regla explicita: excluir modelos constantes/AICc no finito; preferir omision
# media al umbral de 10% <= 0.10, ordenar por AICc y luego AUC de validacion.
# Si ninguno cumple omision, usar menor omision y luego AICc, dejando aviso.
ok <- is.finite(tabla$AICc) & tabla$ncoef > 0 & is.finite(tabla$or.10p.avg) & is.finite(tabla$auc.val.avg)
candidatos <- which(ok & tabla$or.10p.avg <= 0.10)
if (!length(candidatos)) {
  candidatos <- which(ok)
  if (!length(candidatos)) stop("No hay modelos no constantes evaluables. Revisar tabla.")
  candidatos <- candidatos[order(tabla$or.10p.avg[candidatos], tabla$AICc[candidatos])]
  criterio <- "Ninguno cumple omision <=0.10; seleccion exploratoria por menor omision y AICc."
} else {
  candidatos <- candidatos[order(tabla$AICc[candidatos], -tabla$auc.val.avg[candidatos])]
  criterio <- "Omision media <=0.10; menor AICc entre modelos no constantes. Seleccion provisional."
}
indice <- candidatos[1]
elegido <- tabla[indice, , drop = FALSE]
modelo <- evaluacion@models[[indice]]
print(elegido)
write.csv(elegido, file.path(salida, "modelo_seleccionado_PROVISIONAL.csv"), row.names = FALSE)
writeLines(criterio, file.path(salida, "criterio_seleccion.txt"))
saveRDS(modelo, file.path(salida, "modelo_seleccionado.rds"))

# 6. PROYECCION SOLO COLOMBIA + VENEZUELA, POR BLOQUES ----------------------
paises_file <- "datos/naturalearth_50m.rds"
if (!file.exists(paises_file)) saveRDS(rnaturalearth::ne_countries(scale = "medium", returnclass = "sf"), paises_file)
paises <- readRDS(paises_file)
region <- paises[paises$adm0_a3 %in% c("COL", "VEN"), ]
stopifnot(nrow(region) == 2)
region <- sf::st_make_valid(region)
rv <- terra::project(terra::vect(region), terra::crs(clima))
regional <- terra::crop(clima, rv, filename = file.path(salida, "clima_CO_VE_rectangulo.tif"), overwrite = TRUE)
regional <- terra::mask(regional, rv, filename = file.path(salida, "clima_CO_VE.tif"), overwrite = TRUE)
names(regional) <- variables
predecir <- function(model, data, ...) as.numeric(predict(model, as.data.frame(data), type = "cloglog", clamp = TRUE))
pred <- terra::predict(regional, modelo, fun = predecir, na.rm = TRUE, cores = 1,
  filename = file.path(salida, "Scytodes_longipes_CO_VE_cloglog.tif"), overwrite = TRUE,
  wopt = list(datatype = "FLT4S", gdal = "COMPRESS=LZW"))
names(pred) <- "suitability"
# Diagnostico de extrapolacion univariada: numero de variables fuera del rango
# del fondo. No sustituye MESS/MOP ni evalua combinaciones ambientales nuevas.
minimos <- vapply(benv, min, numeric(1)); maximos <- vapply(benv, max, numeric(1))
fuera <- function(x) {
  if (is.null(dim(x))) x <- matrix(x, ncol = length(variables), byrow = TRUE)
  rowSums(sweep(x, 2, minimos, "<") | sweep(x, 2, maximos, ">"))
}
terra::app(regional, fun = fuera, filename = file.path(salida, "variables_fuera_rango_CO_VE.tif"), overwrite = TRUE)

# 7. MAPA: VIRIDIS, MAR AZUL CLARO, TIERRA GRIS, MERCATOR -------------------
# Mostrar solo presencias usadas en el modelo; enlazar procedencia por coords.
procedencia <- read.csv("datos/procedencia.csv")
# Wallace redondea a 5 decimales: tolerancia explicita, exigir enlace unico.
m <- vapply(seq_len(nrow(occs)), function(i) {
  z <- which(abs(procedencia$longitude - occs$longitude[i]) < 0.000011 &
             abs(procedencia$latitude - occs$latitude[i]) < 0.000011)
  if (length(z) != 1) stop("Enlace de procedencia ausente/ambiguo: fila ", i)
  z
}, integer(1))
occs$source <- procedencia$source[m]
occs$countryCode <- procedencia$countryCode[m]
occs$tipo <- ifelse(grepl("GBIF", occs$source), "GBIF", ifelse(occs$countryCode == "CO", "New records - Colombia", "New records - Venezuela"))
pts <- sf::st_as_sf(occs, coords = xy, crs = 4326, remove = FALSE)
pts <- pts[lengths(sf::st_intersects(pts, region)) > 0, ]
merc <- "+proj=merc +lon_0=-73 +datum=WGS84 +units=m +no_defs"
pm <- terra::project(pred, merc, method = "near", filename = file.path(salida, "mapa_mercator.tif"), overwrite = TRUE)
md <- as.data.frame(pm, xy = TRUE, na.rm = TRUE); names(md)[3] <- "suitability"
marco <- sf::st_as_sfc(sf::st_bbox(c(xmin=-82.0, ymin=-5, xmax=-59, ymax=14), crs=sf::st_crs(4326)))
lim <- sf::st_bbox(sf::st_transform(marco, merc))
vecinos <- suppressWarnings(sf::st_crop(paises, sf::st_bbox(marco)))
etiquetas <- sf::st_as_sf(data.frame(nombre=c("COLOMBIA", "VENEZUELA"), x=c(-73.5,-65.5), y=c(2.2,7.8)), coords=c("x","y"), crs=4326)
pie <- sprintf("%s | RM %.1f | n = %d | Mean validation AUC %.3f +/- %.3f SD\nWorldClim 2.1, 2.5 arcmin | Natural Earth 1:50m | WGS84 / Mercator\nProvisional model; grey land: no prediction. Only retained occurrences are shown.", elegido$fc, elegido$rm, nrow(occs), elegido$auc.val.avg, elegido$auc.val.sd)
grafico <- ggplot2::ggplot() +
  ggplot2::geom_sf(data=vecinos, fill="#f1f0ea", colour=NA) +
  ggplot2::geom_raster(data=md, ggplot2::aes(x=x,y=y,fill=suitability)) +
  ggplot2::scale_fill_viridis_c(name="Cloglog model output", limits=c(0,1), option="D") +
  ggplot2::geom_sf(data=vecinos, fill=NA, colour="#575757", linewidth=0.35) +
  ggplot2::geom_sf(data=pts, ggplot2::aes(shape=tipo, colour=tipo), size=2.4, stroke=0.6, fill="white") +
  ggplot2::scale_shape_manual(name=NULL, values=c("GBIF"=21,"New records - Colombia"=24,"New records - Venezuela"=23)) +
  ggplot2::scale_colour_manual(name=NULL, values=c("GBIF"="#172329","New records - Colombia"="#ec734a","New records - Venezuela"="#c4a120")) +
  ggplot2::geom_sf_label(data=etiquetas, ggplot2::aes(label=nombre), size=3, fontface="bold", colour="#475057", fill="white", label.size=NA) +
  ggspatial::annotation_scale(location="bl", width_hint=0.22) +
  ggspatial::annotation_north_arrow(location="tr", style=ggspatial::north_arrow_minimal) +
  ggplot2::coord_sf(crs=merc, xlim=c(lim["xmin"],lim["xmax"]), ylim=c(lim["ymin"],lim["ymax"]), expand=FALSE) +
  ggplot2::labs(title=expression(italic(Scytodes~longipes)), subtitle="Exploratory climatic suitability", caption=pie, x=NULL, y=NULL) +
  ggplot2::theme_minimal(base_size=11) +
  ggplot2::theme(panel.background=ggplot2::element_rect(fill="#eaf1f5",colour=NA), panel.grid.major=ggplot2::element_line(colour="#7c919c",linewidth=0.15),
    plot.background=ggplot2::element_rect(fill="white",colour=NA), legend.position="bottom", legend.box="vertical", plot.title=ggplot2::element_text(size=20,colour="#172a35"),
    plot.subtitle=ggplot2::element_text(colour="#53616c"), plot.caption=ggplot2::element_text(hjust=0,size=8,colour="#64717b"))
print(grafico)
prefijo <- file.path("mapas", paste0("Scytodes_longipes_", METODO))
ggplot2::ggsave(paste0(prefijo,".png"), grafico, width=12, height=10, dpi=400, bg="white")
ggplot2::ggsave(paste0(prefijo,".pdf"), grafico, width=12, height=10, bg="white")
ggplot2::ggsave(paste0(prefijo,".tif"), grafico, width=12, height=10, dpi=400, compression="lzw", bg="white")
writeLines(capture.output(sessionInfo()), file.path(salida, "sessionInfo.txt"))
message("Terminado. Tablas y GeoTIFF: ", normalizePath(salida), "; figuras: ", normalizePath("mapas"))

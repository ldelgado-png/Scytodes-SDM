# 4. Proyeccion regional y mapa.
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
  filename = file.path(salida, "Scytodes_fusca_CO_VE_cloglog.tif"), overwrite = TRUE,
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
occs$tipo <- ifelse(occs$source=="GBIF","GBIF",ifelse(occs$countryCode=="CO","New records - Colombia","New records - Venezuela"))
pts <- sf::st_as_sf(occs, coords = xy, crs = 4326, remove = FALSE)
pts <- pts[lengths(sf::st_intersects(pts, region)) > 0, ]
pts$point_fill <- ifelse(pts$tipo=="GBIF","white",ifelse(pts$tipo=="New records - Colombia","#ec734a","#efc84a"))
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
  ggplot2::geom_sf(data=pts, ggplot2::aes(shape=tipo), size=2.4, stroke=0.6, colour="#172329", fill=pts$point_fill) +
  ggplot2::scale_shape_manual(name=NULL, values=c("GBIF"=21,"New records - Colombia"=24,"New records - Venezuela"=23), limits=c("GBIF","New records - Colombia","New records - Venezuela"), drop=FALSE) +
  ggplot2::geom_sf_label(data=etiquetas, ggplot2::aes(label=nombre), size=3, fontface="bold", colour="#475057", fill="white", linewidth=0) +
  ggspatial::annotation_scale(location="bl", width_hint=0.22) +
  ggspatial::annotation_north_arrow(location="tr", style=ggspatial::north_arrow_minimal) +
  ggplot2::coord_sf(crs=merc, xlim=c(lim["xmin"],lim["xmax"]), ylim=c(lim["ymin"],lim["ymax"]), expand=FALSE) +
  ggplot2::labs(title=expression(italic(Scytodes~fusca)), subtitle="Exploratory climatic suitability", caption=pie, x=NULL, y=NULL) +
  ggplot2::theme_minimal(base_size=11) +
  ggplot2::theme(panel.background=ggplot2::element_rect(fill="#eaf1f5",colour=NA), panel.grid.major=ggplot2::element_line(colour="#7c919c",linewidth=0.15),
    plot.background=ggplot2::element_rect(fill="white",colour=NA), legend.position="bottom", legend.box="vertical", plot.title=ggplot2::element_text(size=20,colour="#172a35"),
    plot.subtitle=ggplot2::element_text(colour="#53616c"), plot.caption=ggplot2::element_text(hjust=0,size=8,colour="#64717b"))
grafico <- grafico + ggplot2::guides(shape=ggplot2::guide_legend(override.aes=list(fill=c("white","#ec734a","#efc84a"))))
print(grafico)
prefijo <- file.path("mapas", paste0("Scytodes_fusca_", METODO))
ggplot2::ggsave(paste0(prefijo,".png"), grafico, width=12, height=10, dpi=400, bg="white")
ggplot2::ggsave(paste0(prefijo,".pdf"), grafico, width=12, height=10, bg="white")
ggplot2::ggsave(paste0(prefijo,".tif"), grafico, width=12, height=10, dpi=400, compression="lzw", bg="white")
writeLines(capture.output(sessionInfo()), file.path(salida, "sessionInfo.txt"))
message("Terminado. Tablas y GeoTIFF: ", normalizePath(salida), "; figuras: ", normalizePath("mapas"))

# 3. Evaluacion de 40 configuraciones y seleccion provisional.
# Particiones y evaluacion tabular
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


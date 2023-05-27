## code to prepare `test_data_binario` dataset goes here

usethis::use_data(test_data_binario, overwrite = TRUE)


#' TCGA RNAseq Samples
#'
#' Pequeña muestra de datos extraídos con TCGABiolinks del repositorio TCGAA
#' Report ...
#'
#' @format ## `TCGA`
#' A data frame with 297 rows and 19950 columns:
#' \describe{
#'  \item{Labels}{Tipo de Tumor}
#'   \item{PacienteID}{ID paciente}
#'   \item{ACTA2|59...}{GENES}
#'
#'   ...
#' }
#' @source <https://portal.gdc.cancer.gov/>
"TCGA"

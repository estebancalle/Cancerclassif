#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  # Objeto reactiveValues para almacenar los datos
  values <- reactiveValues(data = NULL)

  # Llama a los módulos y pasa el objeto values como parámetro

  mod_Home_server("Home_1")

  mod_upload_and_validate_data_server("upload_and_validate_data_1", values = values)

  mod_Classify_patients_server("Classify_patients_1", values = values)

  mod_IA_info_server("IA_info_1")
}

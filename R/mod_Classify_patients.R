#' Classify_patients UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import dplyr
#' @import here
#' @import caret
#' @import tidyselect
#' @import tibble
#' @import stats
#' @import reactable
#' @import reactablefmtr
#' @import htmltools
#' @import scales
#' @import glue
#'
mod_Classify_patients_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        width = 12,
        bs4Dash::box(
          title = "Modo de clasificación",
          id = ns("modebox"),
          icon = icon("list"),
          solidHeader = FALSE,
          gradient = FALSE,
          collapsible = TRUE,
          closable = FALSE,
          width = 12,
          shinyWidgets::radioGroupButtons(
            ns("category"),
            "Selecciona modo de clasificación:",
            choices = c("Binario","Multiclase: 15"),
            selected = NULL,
            status = "primary",
            justified = TRUE,
            individual = TRUE,
            checkIcon = list(
              yes = icon("ok",
                         lib = "glyphicon"),
              no = icon("remove",
                        lib = "glyphicon"))
          )
))),
  fluidRow(
    column(
      width = 4,
      bs4Dash::box(
        title = "Iniciar Clasificación",
        id = ns("classbtbox"),
        icon = icon("flask"),
        solidHeader = FALSE,
        gradient = FALSE,
        collapsible = TRUE,
        closable = FALSE,
        width = 12,
        shinyWidgets::actionBttn(
          inputId = ns("init_class"),
          label = "Iniciar Clasificación",
          style = "unite",
          justified = TRUE,
          color = "success",
          icon = icon("check")
        )
      )),
    column(
      width= 8,
      bs4Dash::box(
        title = "Información modo seleccionado",
        id = ns("infoclassbox"),
        status = "warning",
        icon = icon("circle-info"),
        color = "black",
        background = "warning",
        solidHeader = TRUE,
        gradient = TRUE,
        collapsible = TRUE,
        closable = FALSE,
        width = 12,
        uiOutput(ns("info_class_box_content"))
        ))),
    fluidRow(
      column(
        width = 12,
        bs4Dash::box(
          title = "Tabla de resultados",
          id = ns("resultsbox"),
          icon = icon("hospital-user"),
          solidHeader = FALSE,
          gradient = FALSE,
          collapsible = TRUE,
          closable = FALSE,
          maximizable = TRUE,
          width = 12,
          uiOutput(ns("mensaje")),
          br(),
          downloadButton(ns("downloadData"), "Descargar en csv"),
          downloadButton(ns("downloadDataex"), "Descargar en excel"),
          shinycssloaders::withSpinner(
          reactable::reactableOutput(ns("tableres")), type = 1, color = "#3c8dbc" , size = 2)


    ))))
}

#' Classify_patients Server Functions
#'
#' @noRd
mod_Classify_patients_server <- function(id, values){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    data2export <- reactiveValues(data = NULL)

    observeEvent(input$category, {
      mode <- switch(input$category,
                     "Binario" = "Binario.",
                     "Multiclase: 15" = "Multiclase."
      )
      parrafo <- switch(input$category,
                        "Binario" = HTML(
                          "<br>Las muestras de los pacientes serán clasificadas como Normal y Tumor.<br> Cada diagnóstico viene acompañado de una probabilidad: Verde: >= 0.75, Amarillo: >= 0.6 &  < 0.75 , Rojo: < 0.6. <br> A nivel interno se comprenden 13 tipos de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LIHC, LUAD, LUSC, PRAD, STAD, THCA."
                        ),
                        "Multiclase: 15" = HTML(
                          "<br>Las muestras de los pacientes serán clasificadas en 15 tumores distintos.<br> Se comprenden 15 tipos distintos de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LGG, LIHC, LUAD, LUSC, PRAD, OV, STAD, PRAD. <br> Cada diagnóstico viene acompañado de una probabilidad: Verde: >= 0.75, Amarillo: >= 0.6 &  < 0.75 , Rojo: < 0.6."
                        )
      )
      output$info_class_box_content <- renderUI({
        HTML(paste(paste(tags$b("Modo de clasificación:", mode), parrafo)))
      })
    })



    output$tableres <- renderReactable({
      req(values$data)
      if (input$category == "Multiclase: 15") {
      req(input$init_class)

      # guardamos dataset en variable local
        df <- values$data

      #df <-readRDS(here("data-raw/test_data.rds")) ## para probar

      # Cargamos parametros preprocesamiento
      preproces_parameters <- readRDS(here("data/modelos/multiclase_15/scale_preproces_parameters.rds"))

      ##Aplicamos preprocesamiento
      df_2_test_scaled <- stats::predict(preproces_parameters, newdata = df)

      # Cargamos datos boruta para extraer los nombres de los genes.
      nombres_test_boruta <- readRDS(here("data/modelos/multiclase_15/names_borutadf.rds"))[-1]

      # seleccionamos los genes en el df
      df_to_class <-  df_2_test_scaled %>% dplyr::select(Sample, PacienteID, tidyselect::all_of(nombres_test_boruta))

      # Cargamos modelo Random Forest - BORUTA
      modelo_rf_boruta <- readRDS(here("data/modelos/multiclase_15/rf_boruta.rda"))


      # Predicciones
      pred_rf_boruta <- stats::predict(modelo_rf_boruta,newdata = df_to_class, type = "raw")
      # Predicciones
      probs_rf_boruta <- stats::predict(modelo_rf_boruta,newdata = df_to_class, type = "prob")


      # Tabla predicciones

      resultados <- tibble(Fecha = Sys.Date(), PacienteID = df_to_class$PacienteID, Muestra = df_to_class$Sample, Diagnostico = as.character(pred_rf_boruta), Probabilidad = round(apply(probs_rf_boruta, 1, max),3) )

      data2export$data15 <- resultados
      # Definir función externa para calcular los colores de relleno

      resultados %>%
        mutate(color_pal = case_when(
          Probabilidad >= 0.75 ~ "#11998e",  # Verde para valores >= 0.75
          Probabilidad >= 0.6 & Probabilidad < 0.75 ~ "#F9D423",  # Amarillo para valores entre 0.74 y 0.6
          TRUE ~ "#b31217"  # Rojo para valores < 0.6
        )) %>%
        reactable::reactable(
          pagination = FALSE,
          filterable = TRUE,
          searchable = TRUE,
          defaultSorted = "PacienteID",
          defaultSortOrder = "desc",
          defaultColDef = colDef(
                cell = data_bars(
                  .,
                  fill_color_ref = "color_pal",
                  box_shadow = TRUE,
                  round_edges = TRUE,
                  bold_text = TRUE,
                  text_position = "inside-end",
                  background = "lightgrey",
                  max_value = 1,
                  number_fmt = scales::percent
                )

            ),
            list(color_pal = colDef(show = FALSE))




        )


      } else {

        req(input$init_class)
        # guardamos dataset en variable local
        df <- values$data

        #df <-readRDS(here("data-raw/test_data.rds")) ## para probar

        # Cargamos parametros preprocesamiento
        preproces_parameters <- readRDS(here("data/modelos/binario/scale_preproces_parameters.rds"))

        ##Aplicamos preprocesamiento
        df_2_test_scaled <- stats::predict(preproces_parameters, newdata = df)

        # Cargamos datos boruta para extraer los nombres de los genes.
        nombres_test_boruta <- readRDS(here("data/modelos/binario/names_borutadf.rds"))

        # seleccionamos los genes en el df
        df_to_class <-  df_2_test_scaled %>% dplyr::select(Sample, PacienteID, tidyselect::all_of(nombres_test_boruta))

        # Cargamos modelo Random Forest - BORUTA
        modelo_svmr_boruta <- readRDS(here("data/modelos/binario/svmr_boruta.rda"))


        # Predicciones
        pred_rf_boruta <- stats::predict(modelo_svmr_boruta,newdata = df_to_class, type = "raw")
        # Predicciones
        probs_rf_boruta <- stats::predict(modelo_svmr_boruta,newdata = df_to_class, type = "prob")


        # Tabla predicciones

        resultados <- tibble(Fecha = Sys.Date(), PacienteID = df_to_class$PacienteID, Muestra = df_to_class$Sample, Diagnostico = as.character(pred_rf_boruta), Probabilidad = round(apply(probs_rf_boruta, 1, max),3) )

        data2export$data2 <- resultados
        # Definir función externa para calcular los colores de relleno

        resultados %>%
          mutate(color_pal = case_when(
            Probabilidad >= 0.75 ~ "#11998e",  # Verde para valores >= 0.75
            Probabilidad >= 0.6 & Probabilidad < 0.75 ~ "#F9D423",  # Amarillo para valores entre 0.74 y 0.6
            TRUE ~ "#b31217"  # Rojo para valores < 0.6
          )) %>%
          reactable::reactable(
            pagination = FALSE,
            filterable = TRUE,
            searchable = TRUE,
            defaultSorted = "PacienteID",
            defaultSortOrder = "desc",
            defaultColDef = colDef(
              cell = data_bars(
                .,
                fill_color_ref = "color_pal",
                box_shadow = TRUE,
                round_edges = TRUE,
                bold_text = TRUE,
                text_position = "inside-end",
                background = "lightgrey",
                max_value = 1,
                number_fmt = scales::percent
              )

            ),
            list(color_pal = colDef(show = FALSE))




          )

      }
    })

    output$mensaje <-  renderUI({

      if (input$category == "Multiclase: 15") {
        req(data2export$data15)
      pacientes <- as.character(dim(data2export$data15)[1])
     h5(glue::glue("Clasificados {pacientes} pacientes:"))
      } else {
        req(data2export$data2)
        pacientes <- as.character(dim(data2export$data2)[1])
        h5(glue::glue("Clasificados {pacientes} pacientes:"))
      }
    })



# Botones de descarga
    output$downloadData <- downloadHandler(
      filename = function() {
        if (input$category == "Multiclase: 15") {
          paste("data_resultados_clasificacion_multiclase_", Sys.Date(), ".csv", sep = "")
        } else if (input$category == "Binario") {
          paste("data_resultados_clasificacion_binaria_", Sys.Date(), ".csv", sep = "")
        }
      },
      content = function(file) {
        if (input$category == "Multiclase: 15") {
          rio::export(data2export$data15, file)
        } else if (input$category == "Binario") {
          rio::export(data2export$data2, file)
        }
      }
    )

    output$downloadDataex <- downloadHandler(
      filename = function() {
        if (input$category == "Multiclase: 15") {
          paste("data_resultados_clasificacion_multiclase_", Sys.Date(), ".xlsx", sep = "")
        } else if (input$category == "Binario") {
          paste("data_resultados_clasificacion_binaria_-", Sys.Date(), ".xlsx", sep = "")
        }
      },
      content = function(file) {
        if (input$category == "Multiclase: 15") {
          rio::export(data2export$data15, file)
        } else if (input$category == "Binario") {
          rio::export(data2export$data2, file)
        }
      }
    )


      })
}

## To be copied in the UI
# mod_Classify_patients_ui("Classify_patients_1")

## To be copied in the server
# mod_Classify_patients_server("Classify_patients_1")

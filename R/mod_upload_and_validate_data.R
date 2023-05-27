#' upload_and_validate_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets switchInput
#' @importFrom rio import
#' @import DT
#' @import data.validator
#' @import dplyr
#' @import here
#' @import shinycssloaders
mod_upload_and_validate_data_ui <- function(id){
  ns <- NS(id)
  tagList(
  fluidRow(
    bs4Dash::box(
      title = "Información: Formato datos permitidos",
      id = ns("infoupdatabox"),
      status = "warning",
      icon = icon("circle-info"),
      color = "black",
      background = "warning",
      solidHeader = TRUE,
      gradient = TRUE,
      collapsible = TRUE,
      collapsed = TRUE,
      closable = FALSE,
      width = 12,
      uiOutput(ns("info_box_content"))
    )),
  fluidRow(
      column(
      width = 4,
      bs4Dash::box(
        title = "Subir archivo",
        id = ns("upbox"),
        icon = icon("file-arrow-up"),
        solidHeader = FALSE,
        gradient = FALSE,
        collapsible = TRUE,
        closable = FALSE,
        width = 12,
        h6(tags$b("Datos de prueba")),
        shinyWidgets::switchInput(
          inputId = ns("File2"),
          onStatus = "success",
          offStatus = "danger"
      ),
        fileInput(ns("File1"),
                "Escoge o arrastra tus datos",
                accept = c(".csv", ".tsv", ".sav", ".dta",".xls",".xlsx",".rds",".rda"),
                multiple = TRUE,
                buttonLabel = "Archivos...",
                placeholder = "No hay un archivo seleccionado",
                ),
        helpText("Tamaño de archivo máximo: 10 MB")



    )),
  column(
    width = 8,
    bs4Dash::tabBox(
      width = 12,
      id = ns("tabcard"),
      side = c("right"),
      icon = icon("database"),
      collapsible = TRUE,
      maximizable = TRUE,
      closable = FALSE,
      selected = "Archivos Cargados",
      status = "info",
      solidHeader = FALSE,
      type = "tabs",
      tabPanel(
        title = "Archivos Cargados",
        h5(tags$b("Selecciona uno de los datasets cargados:")),
        helpText("Click sobre la tabla"),
        br(),
        br(),
        DT::DTOutput(ns("files"))
      ),
      tabPanel(
        title = "Preview dataset seleccionado",
        id = "Tab 2",
        DT::DTOutput(ns("head"))
      ),
      tabPanel(
        title = "Validar dataset seleccionado",
        shinyWidgets::actionBttn(
          inputId = ns("init_validation"),
          label = "Iniciar validación de datos",
          style = "unite",
          color = "success",
          icon = icon("check")
        ),
        br(),
        br(),
        shinycssloaders::withSpinner(
        uiOutput(ns("validation")), type = 1, color = "#3c8dbc" , size = 2)


      )
    ))


))
}

#' upload_and_validate_data Server Functions
#'
#' @noRd
mod_upload_and_validate_data_server <- function(id, values){
  moduleServer( id, function(input, output, session){

    ns <- session$ns

    options(shiny.maxRequestSize = 10 * 1024^2)

    output$info_box_content <- renderUI({
      HTML("<br>Se admiten los archivos con los siguientes formatos: .csv, .tsv, .sav, .dta, .xls, .xlsx, .rds, .rda <br>&bull; Los genes deben estar en las columnas y las muestras en las filas. Las dos primeras columnas deben ser: Sample y PacienteID de formato caracter o factor. <br>&bull; Las muestras deben haber sido alineadas con el genoma de referencia hg19. <br>&bull; Las anotaciones de los genes (nombres de las columnas) deben estar formadas por 'nombre_gen|entrezgeneID' (Ej: NAT2|10). Consultar BiomaRt para más info.")
    })



    # Activacion datos tests
    load_test_data <- reactiveVal(FALSE)

    observeEvent(input$File2, {
      load_test_data(input$File2)
    })



    # Cargar el archivo "test_data.rda" cuando load_test_data sea TRUE
    test_file <- reactive({
      if (load_test_data()) {
        #load("data/test_data.rda")
        file_path_multi <- "data-raw/test_data_multiclase.rds"
        file_path_binario <- "data-raw/test_data_binario.rds"
        file_info <- data.frame(
          name = c(basename(file_path_multi), basename(file_path_binario)),
          size = c(basename(file_path_multi), basename(file_path_binario)),
          type = c("RDS","RDS")
        )
        file_info


        #test_data
      } else {
        NULL
      }
    })


    # Combinar los datos subidos por el usuario con el archivo "test_data.rda"
    combined_data <- reactive({
      uploaded_data <- input$File1
      if (!is.null(uploaded_data)) {
        rbind(test_file(), uploaded_data[,1:3])
      } else {
        test_file()
      }
    })
    #Tabla de archivos subidos
    output$files <- renderDT(combined_data()[,-4], selection = "single")


    # Reactive value to store the selected dataset from the files table
    selected_dataset <- reactiveVal(NULL)

    # Reactive value para almacenar los values
    #values <- reactiveValues(data = NULL)


    # Update the selected dataset when a row is clicked in the files table
    observeEvent(input$files_rows_selected, {
      selected_rows <- input$files_rows_selected
      if (length(selected_rows) > 0) {
        selected_dataset(combined_data()[selected_rows, ])
      } else {
        selected_dataset(NULL)
      }
    })

    # Control de tipo de datos subidos por el usuario para la preview
    data <- reactive({
      req(input$File1)
      ext <- tools::file_ext(input$File1$name)
      extentions <- c("csv", "tsv", "sav", "dta","xls","xlsx","rds","rda")
      if (ext %in% extentions){

        rio::import(input$File1$datapath, setclass = "data.frame")
      }
      else {
        validate("Archivo no válido; Por favor, revisa los formatos admitidos")
      }

      })

    # Función para leer el archivo de datos
    readDataFile <- function(file) {
      if (file == "test_data_multiclase.rds") {
        return(readRDS("data-raw/test_data_multiclase.rds")[,-3])
      } else if (file == "test_data_binario.rds") {
        return(readRDS("data-raw/test_data_binario.rds")[,-3])
      } else {
        return(data())
      }
    }

    # df <- selected_dataset()
    # values$data <- readDataFile(df$name)

    # Render the selected dataset in the head table
    output$head <- renderDT({
      df <- selected_dataset()
      if (!is.null(df)) {
        df <- readDataFile(df$name)
        values$data <- df  # Almacenar los datos seleccionados en values$data
        DT::datatable(head(df, n=10)[,1:10], options = list(
          scrollX = TRUE,
          columnDefs = list(
            list(width = '100px', targets = "_all")
          )
        ))
      }
    })

    output$validation <- renderUI({NULL})

    observeEvent(input$init_validation, {
      req(selected_dataset())
      output$validation <- renderUI({})

      report <- data_validation_report()
      validate_data <- reactive({
        df <- selected_dataset()
        if (!is.null(df)) {
          df2classif <- readDataFile(df$name)
        }
        df2classif  # Return the data frame
      })

      df2 <- validate_data()
      #num_cols <- names(df2)[-1]  # Obtener los nombres de las columnas numéricas
      df2 %>%
      data.validator::validate("Resultado tests", description = "Dataset Validation Test") %>%
        #validate_cols(is_character(), Labels, description = "La primera columna de pacientes es de tipo caracter") %>%
        validate_cols(predicate = not_na, description = "No  hay valores faltantes") %>%
        #validate_cols(is.numeric(), description = "cols numerics") %>%
        #validate_if(predicate = data.validator::is_uniq(Labels), description = "No rep values") %>%
        validate_if(is.factor(PacienteID) | is.character(PacienteID),  description = "La columna PacienteID es de tipo caracter o factor") %>%
        validate_if(is.factor(Sample) | is.character(Sample),  description = "La columna Sample es de tipo caracter o factor") %>%
        validate_cols(is.numeric, 3:last_col(), description = "Todas las columnas, excepto las dos primeras, deben ser numéricas.") %>%
        #validate_cols(any_of("NAT2|10"), 3:last_col(), description = "Los genes están en las columnas") %>%
        #validate_if(function(data, col) !col %in% num_cols || is.numeric(data), description = "Todas las columnas, excepto la primera, deben ser numéricas.") %>%

        #validate_if(is.factor(1),  description = "Labels numeber column es factor") %>%
        #validate_if(is.factor(names(df2)[1]),  description = "Labels names column es numeric") %>%
        #validate_if(is.numeric(names(df2[-1])),  description = "if column is NUMERIC") %>% # FALLO
       # validate_if(is.numeric(df2[-1]), "Todas las columnas, excepto la primera, deben ser numéricas.") %>% # FALLO


        #validate_rows(is_uniq, 1, description = "not too many NAs in rows") %>%
        #validate_cols(in_set(c(0, 2)), vs, am, description = "vs and am values equal 0 or 2 only") %>%
        #validate_cols(within_n_sds(1), mpg, description = "mpg within 1 sds") %>%
        #validate_rows(num_row_NAs, within_bounds(0, 2), vs, am, mpg, description = "not too many NAs in rows") %>%
        #validate_rows(is, within_n_mads(10), everything(), description = "maha dist within 10 mads") %>%
        add_results(report)
      output$validation <- renderUI({
        render_semantic_report_ui(get_results(report = report))
      })
    })




    # Retorno del dataset seleccionado
    #return(df2classif)
    # ¿hacerlo global?


    #return(values)
    #return(toReturn)

  })
}




## To be copied in the UI
# mod_upload_and_validate_data_ui("upload_and_validate_data_1")

## To be copied in the server
# mod_upload_and_validate_data_server("upload_and_validate_data_1")

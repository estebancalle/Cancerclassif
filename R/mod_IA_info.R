#' IA_info UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import here
#' @import plotly
#' @import rio
#'
mod_IA_info_ui <- function(id){
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
            ns("category2"),
            "Selecciona el modo de clasificación para obtener su información:",
            choices = c("Binario","Multiclase: 15"),
            selected = "Multiclase: 15",
            status = "success",
            justified = TRUE,
            individual = TRUE

        )))),

    fluidRow(
    bs4Dash::box(
      title = "Información: Entrenamiento de los algoritmos",
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
      uiOutput(ns("infoupdatabox"))
    )),

    fluidRow(
    column(
      width = 4,
      bs4Dash::tabBox(
        width = 12,
        id = ns("muestrasplotbox"),
        side = c("right"),
        icon = icon("database"),
        collapsible = TRUE,
        maximizable = TRUE,
        closable = FALSE,
        selected = "Gráfico de muestras",
        status = "info",
        solidHeader = FALSE,
        type = "tabs",
        tabPanel(
          title = "Gráfico de muestras",
          h6(tags$b("Numero de muestras por tipo de tumor utilizadas para entrenar los algoritmos")),
          plotlyOutput(ns("mi_grafico"))
        ),
        tabPanel(
          title = "Tabla de muestras",
          DT::DTOutput(ns("tablenum"))
        )




      )),

    column(
      width = 4,
      bs4Dash::tabBox(
        width = 12,
        id = ns("tabcard"),
        side = c("right"),
        icon = icon("magnifying-glass-chart"),
        collapsible = TRUE,
        maximizable = TRUE,
        closable = FALSE,
        selected = "T-SNE",
        status = "info",
        solidHeader = FALSE,
        type = "tabs",
        tabPanel(
          title = "T-SNE",
          h6(tags$b("Gráfico de reducción de dimensionalidad de las muestras de entrenamiento")),
          plotlyOutput(ns("TSNE"))
        ),
        tabPanel(
          title = "UMAP",
          h6(tags$b("Gráfico de reducción de dimensionalidad de las muestras de entrenamiento")),
          plotlyOutput(ns("UMAP"))
        )

      )),
    column(
      width = 4,
      bs4Dash::box(
        title = "Hierarchical clustering",
        id = ns("muestrasplotbox"),
        icon = icon("magnifying-glass-chart"),
        solidHeader = FALSE,
        gradient = FALSE,
        collapsible = TRUE,
        maximizable = TRUE,
        closable = FALSE,
        width = 12,
        h6(tags$b("Hierarchical clustering muestras de entrenamiento")),
        uiOutput(ns("image_output"))




      )))

  )
}




#' IA_info Server Functions
#'
#' @noRd
mod_IA_info_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  # importamos gráficos multiclase
  grafico15 <- readRDS("data/plots/plot_num_tumor15.rds")
  tsne15 <- readRDS("data/plots/tsne_plot.rds")
  umap15 <- readRDS("data/plots/umap_plot.rds")

  # importamos gráficos binarios
  grafico2 <- readRDS("data/plots/plot_num_tumor2.rds")
  tsne2 <- readRDS("data/plots/tsne_plotly2.rds")
  umap2 <- readRDS("data/plots/umap_plotly2.rds")







  observeEvent(input$category2, {
    mode <- switch(input$category2,
                   "Binario" = "Binario",
                   "Multiclase: 15" = "Multiclase: 15 Tumores.")
    parrafo <- switch(
      input$category2,
      "Binario" = HTML(
        "<br>Clasifica las muestras de RNA-Seq de los pacientes en Normal o Tumor. Para ello:<br>&bull; Las muestras son estandarizadas. <br>&bull;  Se seleccionan los genes selecionados por el método boruta en el entrenamiento. Boruta realiza una búsqueda de tipo Backwards mediante un algoritmo wrapper de Random Forest. <br>&bull; Se utiliza el algoritmo de machine learning Support Vector Machine de kernel radial (SVMR). <br>&bull; A nivel interno las clases Normal y Tumor comprenden 13 tipos de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LIHC, LUAD, LUSC, PRAD, STAD, THCA."
      ),
      "Multiclase: 15" = HTML(
        "<br>Clasifica las muestras de RNA-Seq de los pacientes en 15 tumores distintos de RNA-Seq. Para ello:<br>&bull; Las muestras son estandarizadas. <br>&bull; Se seleccionan los genes selecionados por el método boruta en el entrenamiento. Boruta realiza una búsqueda de tipo Backwards mediante un algoritmo wrapper de Random Forest. <br>&bull; Se utiliza el algoritmo de machine learning Random Forest (RF). <br>&bull; Se comprenden 15 tipos de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LGG, LIHC, LUAD, LUSC, PRAD, OV, STAD, PRAD."
      )
    )

    output$infoupdatabox <- renderUI({
      HTML(paste(tags$b("Modo de clasificación:", mode), parrafo))
    })

  })


  output$mi_grafico <- renderPlotly({
    if (input$category2 == "Multiclase: 15") {
    grafico15
    } else {
      grafico2
    }
  })


  output$TSNE <- renderPlotly({
    if (input$category2 == "Multiclase: 15") {
    tsne15
    } else {
      tsne2
    }
  })

  output$UMAP <- renderPlotly({
    if (input$category2 == "Multiclase: 15") {
    umap15
  } else {
    umap2
  }
  })

  output$image_output <- renderUI({
    if (input$category2 == "Multiclase: 15") {
    tags$img(src = "www/dendro_plot15.png", width = "100%")
  } else {
    tags$img(src = "www/dendro_plot2.png", width = "100%")
  }
  })

  output$tablenum <- renderDT({
    if (input$category2 == "Multiclase: 15") {
    dftablesamples <- rio::import(here("data/muestras_ai_multiclase.csv"))
    DT::datatable(dftablesamples[-2], options = list(
    scrollX = TRUE, pageLength = 14
    ))
  } else {
    df <- rio::import(here("data/muestras_ai_binario.csv"))

      DT::datatable(
        (df),
        escape = FALSE,
        options = list(
          scrollX = TRUE, pageLength = 14
        ))

  }
  })




  })
}





## To be copied in the UI
# mod_IA_info_ui("IA_info_1")

## To be copied in the server
# mod_IA_info_server("IA_info_1")

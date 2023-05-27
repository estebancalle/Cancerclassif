#' Home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Home_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      bs4Dash::box(
        title = "¡Bienvenido a CanceRClassif!",
        id = ns("bienvenido"),
        status = "lightblue",
        icon = icon("hands-clapping"),
        color = "black",
        solidHeader = TRUE,
        gradient = FALSE,
        collapsible = TRUE,
        collapsed = FALSE,
        closable = FALSE,
        width = 12,
       tags$b(h3("Podrás clasificar las muestras de tus pacientes como herramienta de apoyo al diagnóstico.")),
       br(),
       h5("Hay dos modos de clasificación:"),
       h6(HTML("&bull; Binaria: Tumor o Normal.")),
       h6(HTML("&bull; Multiclase: entre 15 tipos de tumores"))


      )),
    fluidRow(
      column(
        width = 4,
        align="center",
        bs4Dash::box(
          title = "1 - Sube tus datos",
          icon = icon("file-arrow-up"),
          solidHeader = FALSE,
          gradient = FALSE,
          collapsible = TRUE,
          closable = FALSE,
          status = "danger",
          width = 12,
          icon("file-arrow-up", class ="fa-solid fa-file-arrow-up fa-10x fa-pull-center", style = "color: #d31212;")
        )),
      column(
        width = 4,
        align="center",
        bs4Dash::box(
          title = " 2 - Valida tus datos",
          icon = icon("circle-check"),
          solidHeader = FALSE,
          status = "success",
          gradient = FALSE,
          collapsible = TRUE,
          closable = FALSE,
          width = 12,
          icon("check", class ="fa-solid fa-circle-check fa-10x fa-pull-center #28a745", style = "color: #28a745;")

        )),
      column(
        width = 4,
        align="center",
        bs4Dash::box(
          title = " 3 - Clasifica las muestras de tus pacientes",
          icon = icon("stethoscope"),
          status = "lightblue",
          solidHeader = FALSE,
          gradient = FALSE,
          collapsible = TRUE,
          closable = FALSE,
          width = 12,
          icon("user-doctor", class ="fa-solid fa-stethoscope fa-10x fa-pull-center", style = "color: #3c8dbc;")

        ))),


  fluidRow(
    bs4Dash::box(
      title = "Aviso legal.",
      id = ns("Disclaimer"),
      status = "warning",
      icon = icon("triangle-exclamation"),
      color = "black",
      background = "warning",
      solidHeader = TRUE,
      gradient = TRUE,
      collapsible = TRUE,
      collapsed = TRUE,
      closable = FALSE,
      width = 12,
      h5(HTML(paste(tags$b("App experimental. Por el momento no es apta ni está autorizada para su uso clínico en un escenario real.")))),
      h5(HTML("&bull;Su uso e implementación se plantea como un apoyo al diagnóstico.")),
      h5(HTML("&bull;CanceRClassif y su autor no se hacen responsables de un uso inadecuado e indebido de la app."))
    )))

}

#' Home Server Functions
#'
#' @noRd
mod_Home_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_Home_ui("Home_1")

## To be copied in the server
# mod_Home_server("Home_1")

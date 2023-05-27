#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bs4Dash
#' @import here
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    ui = dashboardPage(
      title = "Basic Dashboard",
      header = dashboardHeader(
        title = dashboardBrand(
          title = "CanceRClassif",
          color = "danger",
          image = "www/hex_CanceRClassif.png"


        )
      ),

      # Sidebar
      sidebar = dashboardSidebar(
        sidebarMenu(
          id = "sidebar",
          menuItem(
            text = "Home",
            tabName = "TabH",
            icon = icon("home"),
            selected = TRUE
          ),
          menuItem(
            text = "Subir y validar datos",
            tabName = "Tab1",
            icon = icon("file-arrow-up")
          ),
          menuItem(
            text = "Clasificar pacientes",
            tabName = "tab2",
            icon = icon("stethoscope")
          ),
          menuItem(
            text = "IA info",
            tabName = "tab3",
            icon = icon("microchip")
          )
        ),
        skin = "light",
        status = "info"
      ),
      controlbar = dashboardControlbar(
        collapsed = TRUE,
        shiny::h3(icon("paint-roller"), "Temas", align = "center"),
        div(class = "p-3", skinSelector()),
        pinned = FALSE,
        title = "Skin Selector",

      ),
      footer = dashboardFooter(fluidRow(
        column(width = 10, HTML("2023 Esteban Calle")),
        column(width = 2, align = "right")
      )),
      body = dashboardBody(fluidRow(width = 12,
        #column(width = 1, h1(tags$b("CanceRClassif"))),
        column(width = 2, img(src = "www/hex_CanceRClassif.png", width = "75px", height = "75px"))
        ),
        br(),
        tabItems(
          tabItem(tabName = "TabH",

                mod_Home_ui("Home_1")
          ),
          tabItem(tabName = "Tab1",
                  mod_upload_and_validate_data_ui("upload_and_validate_data_1")
          ),
          tabItem(tabName = "tab2",
                  mod_Classify_patients_ui("Classify_patients_1")),
          tabItem(tabName = "tab3",
                  mod_IA_info_ui("IA_info_1"))

        ))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Cancerclassif"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
 #tags$img(src = "www/hex_CanceRClassif.png", height = "30px") )
)

}

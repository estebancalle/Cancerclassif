
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CanceRClassif <img src="man/figures/hex_CanceRClassif.png" align="right" alt="CanceRClassif logo" style="height: 140px;"></a>

> *Clasifica y detecta tumores en muestras de tejidos RNA-Seq de tus pacientes utilizando una aplicación web desarrollada en Shiny. La aplicación emplea un modelo de machine learning basado en Random Forest, optimizado con el algoritmo de selección de características Boruta, para clasificaciones a nivel binario (tumorales o normales) y multiclase (15 tipos de cáncer. Los resultados vienen acompañados de un diagnóstico y su probabilidad*

<!-- badges: start -->
<!-- badges: end -->

![](man/figures/cancerclassifdemo.gif)

## Descripción

`CanceRClassif` es una aplicación web interactiva y fácil de usar desarrollada en Shiny para la clasificación y/o detección de cáncer. La aplicación ermite clasificar y detectar tumores en muestras de tejidos RNA-Seq de pacientes. Utiliza un modelo de machine learning basado en Random Forest, optimizado con el algoritmo de selección de características Boruta, proporcionando una clasificación binaria (Tumor o Normal) y multiclase (15 tipos distintos de cáncer). Los resultados vienen acompañados de un diagnóstico y su probabilidad.

## Modos de Clasificación
- **Binaria**: Clasifica las muestras como Tumor o Normal. Comprende 13 tipos de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LIHC, LUAD, LUSC, PRAD, STAD, THCA.
- **Multiclase**: Distingue y clasifica 15 tipos diferentes de tumores: BLCA, BRCA, CESC, COAD, HNSC, KIRC, KIRP, LGG, LIHC, LUAD, LUSC, PRAD,   OV, STAD, PRAD

Los resultados de la clasificación, incluyendo las probabilidades asociadas, pueden descargarse en formato .csv y .xlsx para su análisis detallado.

## Modelo y Pipeline
El modelo de clasificación utilizado en CanceRClassif proviene de un pipeline de selección y entrenamiento de modelos utilizando datos RNA-Seq del proyecto TCGA (https://portal.gdc.cancer.gov/). Este [pipeline]((https://github.com/estebancalle/tcga_cancer_classification) incluye la extracción, transformación, preprocesamiento, estandarización, selección y extracción de características, análisis exploratorio de datos (EDA), clustering, y la implementación de algoritmos de machine learning (ML) y deep learning (DL).

El modelo seleccionado es un Random Forest, optimizado con un algoritmo de selección de características (Boruta) para identificar los genes más relevantes para la clasificación.

Para más detalles sobre el pipeline y el proceso de selección del modelo, visita el siguiente repositorio: [Cancer Classification Pipeline](https://github.com/estebancalle/tcga_cancer_classification)

## Instalación

**Online:**

Utiliza la herramienta desplegada en el servidor web *shinyapps.io*:

[CanceRClassif Web](https://estebancalle.shinyapps.io/Cancerclassif/)

**Instalación local**

`CanceRClassif` es una app construida como paquete de R. Puedes instalarla y ejecutarla localmente con los siguientes comandos:

``` r
# Instala
remotes::install_github("estebancalle/Cancerclassif")

# Activa la librería
library(Cancerclassif)

# Lanza la aplicación
run_app()
```

## Modo de empleo: 

### Proceso de Clasificación

1.  **Sube tus datos**: La aplicación acepta archivos en formatos .csv, .tsv, .sav, .dta, .xls, .xlsx, .rds, .rda.
2.  **Valida el dataset**: Previsualiza y confirma el formato del dataset.
3.  **Clasifica los pacientes**: Selecciona el modo de clasificación deseado y obtén los resultados, los cuales pueden descargarse.

### Subir los datos y validarlos.

- **Estructura**: Genes en columnas y muestras en filas.
- **Columnas iniciales**: 'Sample' y 'PacienteID' deben ser las dos primeras columnas.
- **Genoma de referencia**: Las muestras deben estar alineadas con hg19.
- **Anotaciones de genes**: Los nombres de las columnas deben seguir el formato 'nombre_gen|entrezgeneID' (Ej: NAT2|10). Consultar   BiomaRt para más info.

### Clasificación y Descarga de Resultados

- **Modo Binario**: Clasifica las muestras como Normal o Tumor. Los resultados vienen acompañados de un diagnóstico y su probabilidad (Verde: ≥ 0.75, Amarillo: ≥ 0.6 & < 0.75, Rojo: < 0.6).
- **Modo Multiclase**: Clasifica las muestras en 15 tipos de tumores distintos. Los resultados vienen acompañados de un diagnóstico y su probabilidad.

Los resultados incluyen fecha de análisis, nombre de la muestra, código identificativo del paciente, diagnóstico y probabilidad. La tabla resultante es interactiva y se puede descargar en formato .csv o .xlsx.

## Información Adicional

En la página "Info IA" del menú de navegación, puedes encontrar más detalles sobre los algoritmos de entrenamiento y las muestras utilizadas para ajustar los modelos de machine learning. Esta transparencia asegura que los usuarios comprendan el funcionamiento interno de la herramienta.

## Personalización
En la barra superior de navegación, puedes cambiar el modo de visualización (claro/oscuro) y personalizar los colores de los menús según tus preferencias, mejorando la experiencia del usuario.

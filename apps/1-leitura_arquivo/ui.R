library(shiny)
library(DT)
library(readxl)
library(readr)

# Interface com todos os controles no painel lateral, incluindo elemento
# para entrada de arquivos.

fluidPage(
  titlePanel("Exemplo de app com leitura de arquivo"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Selecione um arquivo .csv ou .xlsx",
                accept = c(".csv", ".xlsx", "xls")),
      numericInput("row", "Linha de início:", value = 1, min = 1, step = 1),
      selectInput("colDate", "Selecione a coluna do mês", choices = c()),
      selectInput("colName", "Selecione a coluna do nome", choices = c()),
      selectInput("colValue", "Selecione a coluna do valor", choices = c())
    ),
    
    mainPanel(tabsetPanel( # Painel com várias abas
      tabPanel("Dados originais", DTOutput("original")),
      tabPanel("Total", DTOutput("total")),
      tabPanel("Gráfico", plotOutput("plot")))
    )
  )
)

library(shiny)
library(DT)
library(dplyr)
library(lubridate)
library(ggplot2)


function(input, output, session) {
  
  arquivo <- reactive({
    req(input$file)
    infile <- input$file
    ext <- tolower(tools::file_ext(input$file$name)) # Extensão do arquivo (se é csv ou xlsx)
    
    tryCatch({
      if(ext %in% c("xls", "xlsx")){
        readxl::read_excel(infile$datapath, skip = input$row - 1)
      } else {
        readr::read_csv(infile$datapath, skip = input$row - 1)
      }
    }, error = function(e) {
      stop(shiny::validate(need(FALSE, paste("Erro na leitura do arquivo:\n", e$message))))
    })
  })
  
  # Quando o arquivo mudar, atualizamos as opções para selecionar as colunas.
  observeEvent(arquivo(), {
    updateSelectInput(session, "colDate", choices = colnames(arquivo()))
    updateSelectInput(session, "colName", choices = colnames(arquivo()))
    updateSelectInput(session, "colValue", choices = colnames(arquivo()))
  })
  
  output$original <- renderDT({
    arquivo()
  })
  
  output$total <- renderDT({
    tryCatch({
      arquivo() |>
        group_by(.data[[input$colName]]) |>
        summarize(Total = sum(.data[[input$colValue]]))
    }, error = function(e) {
      stop(shiny::validate(FALSE, "Seleção de colunas inválida."))
    })
  })
  
  output$plot <- renderPlot({
    tryCatch({
      df <- arquivo()
      datas <- suppressWarnings(lubridate::dmy(df[[input$colDate]]))
      datas[is.na(datas)] <- suppressWarnings(lubridate::my(df[[input$colDate]][is.na(datas)]))
      df |>
        mutate(mes = datas) |>
        group_by(mes, .data[[input$colName]]) |>
        summarize(Total = sum(.data[[input$colValue]]), .groups = "drop") |>
        ggplot(aes(x = mes, y = Total, color = .data[[input$colName]])) +
        geom_line()
    }, error = function(e) {
      stop(shiny::validate(FALSE, e$message)) #"Seleção de colunas inválida ou formato de data ambíguo."))
    })
  })
  
}

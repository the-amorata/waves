source("~/ShinyApps/waves-dev/util.r")
function(input, output, session) { 
  
  #Plot Parameters
  pp <- reactiveValues()
  observe({
    pp$mp3 <- input$mp3
    pp$hex <- input$hex
    pp$lab <- input$lab
    pp$mag <- input$mag
    pp$det <- input$detail
    pp$fam <- input$fam
    pp$fl  <- input$fl
    pp$lw  <- input$lw
    pp$is  <- input$image_size
    pp$ss  <- input$shirt_size
    pp$sc  <- input$shirt_color
  })
  
  output$control_panel <- renderUI({
    validate(need(input$image_size != '', 'Choose A Product To Get Started'))
    validate(need(input$mp3, 'Upload A File'))
    if (input$image_size == 'Across Chest (10X12)') big_control_panel()
    else if (input$image_size == 'Left Pocket (3X2)') small_control_panel()
  })
  
  output$button <- renderUI({
    validate(need(input$image_size != '', ''))
    validate(need(input$mp3, ''))
    validate(need(input$shirt_size != '', 'Choose A Shirt Size'))
    validate(need(input$shirt_color != '', 'Choose A Shirt Color'))
    actionButton('order', "Order!")
  })
  
  output$wave <- renderPlot({
    validate(need(input$image_size, ''))
    validate(need(input$mp3, ''))
    validate(need(input$detail, ''))
    validate(need(input$hex, ''))
    if (input$image_size == 'Across Chest (10X12)') validate(need(input$lw, ''))
    plot_wave(reactiveValuesToList(pp))
  }, height = function() {
    (session$clientData$output_wave_width)*(2/3)
  })

  observeEvent(input$example, {
    showModal(modalDialog(
      title = "Samples",
      sample_ligtbox(),
      easyClose = TRUE
    ))
  })

  onclick("order", {
    fn = plot_wave(reactiveValuesToList(pp), TRUE)
    js$order(mk_url(fn))
  })
      
}

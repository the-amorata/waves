source("~/apps/waves/util.r")
 
function(input, output, session) { 
  
  #Plot Parameters
  pp <- reactiveValues()
  x <- reactiveValues()
  
  observe({
    pp$hex <- input$hex
    pp$lab <- input$lab
    pp$mag <- input$mag
    pp$det <- input$detail
    pp$fam <- input$fam
    pp$fl  <- input$fl
    pp$lw  <- input$lw
    pp$ss  <- input$shirt_size
    pp$sc  <- input$shirt_color
  })
  
  observeEvent(input$audio, {
    x$mp3 <- NULL
    audio <- gsub(' ', '+', gsub('data:audio/wav;base64,', '', input$audio))
    audio <- openssl::base64_decode(audio)
    
    tfile <- tempfile(fileext='.wav')
    writeBin(audio, tfile)

    x$mp3 <- tuneR::readWave(tfile)
    file.remove(tfile)
  })
  
  output$control_panel <- renderUI({
    validate(need(input$image_size, ''))
    validate(need(x$mp3, ''))
    if (input$image_size == 'across chest 11"x6"') big_control_panel()
    else if (input$image_size == 'left pocket 3"x1.6"') small_control_panel()
  })
  
  output$button <- renderUI({
    validate(need(input$image_size, ''))
    validate(need(x$mp3, ''))
    validate(need(input$shirt_size, 'choose a shirt size'))
    validate(need(input$shirt_color, 'choose a shirt color'))
    actionButton('order', "PROCEED TO CHECKOUT")
  })
  
  output$wave <- renderPlot({
    validate(need(input$image_size, ''))
    validate(need(x$mp3, ''))
    validate(need(input$detail, ''))
    validate(need(input$hex, ''))
    if (input$image_size == 'across chest 11"x6"') validate(need(input$lw, ''))
    plot_wave(reactiveValuesToList(pp), x$mp3, input$image_size) 
  }, height = function() {
    (session$clientData$output_wave_width)*(2/3)
  })
  
  output$mic <- renderUI({
    validate(need(input$image_size, ''))
    tags$div(
      tags$div(
        id = 'viz',
        HTML("
          <canvas id=\"analyser\" width=\"0\" height=\"0\"></canvas>
          <canvas id=\"wavedisplay\" width=\"0\" height=\"0\"></canvas>")),
      tags$div(
        id = 'controls',
        HTML("
          <img id=\"record\" src=\"mic128.png\" onclick=\"toggleRecording(this);\">
          <a id=\"save\" href=\"#\"><img src=\"save.svg\"></a>")),
      br()
    )
  })

  observeEvent(input$example, {
    showModal(modalDialog(
      title = "samples",
      sample_ligtbox(),
      easyClose = TRUE
    ))
  })

  onclick("order", {
    fn = plot_wave(reactiveValuesToList(pp), x$mp3, input$image_size, TRUE) 
    js$order(mk_url(fn, input$shirt_size, input$shirt_color, input$image_size))
  })
      
}

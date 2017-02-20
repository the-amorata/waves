source("~/apps/waves/util.r")

ids = c('21393505797', '24373225925', '24373305733')
 
function(input, output, session) { 
  
  ### PARAMETERS ###
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
  })
  
  ### CREATE ###
  
  observeEvent(input$audio, {
    x$mp3 <- NULL
    audio <- gsub(' ', '+', gsub('data:audio/wav;base64,', '', input$audio))
    audio <- openssl::base64_decode(audio)
    
    tfile <- tempfile(fileext='.wav')
    writeBin(audio, tfile)
    
    x$mp3 <- tuneR::readWave(tfile)
    file.remove(tfile)
  })
  
  output$mic <- mic_ui
  
  output$sample_wave <- renderImage({
    validate(need(x$mp3, ''))
    
    w = session$clientData$output_sample_wave_width; h = w*(2/3)
    outfile = tempfile(fileext='.png')
    
    png(file = outfile, width = 1200, height = 800, res = 120)
    # sample_plot(x$mp3,  input$image_size)
    sample_plot(x$mp3)
    dev.off()
    
    # Return a list
    list(src = outfile,
         width  = w,
         height = h,
         alt = "trouble loading image")
  }, deleteFile = TRUE)
  
  ### PERSONALIZE ###
  
  output$hex_test <- renderPrint({input$hex})
  
  output$control_panel <- renderUI({
    validate(need(x$mp3, ''))
    if (input$image_size == 'across chest 11"x6"') big_control_panel()
    else if (input$image_size == 'left pocket 3"x1.6"') small_control_panel()
  })
  
  output$wave <- renderImage({
    validate(need(input$image_size, ''))
    validate(need(x$mp3, ''))
    validate(need(input$hex, ''))
    if (input$image_size == 'across chest 11"x6"') validate(need(input$lw, ''))
    
    w = session$clientData$output_wave_width; h = w*(2/3)
    outfile = tempfile(fileext='.png')
    
    # Generate a png
    png(file = outfile, width = 1200, height = 800, res = 120)
    plot_wave(reactiveValuesToList(pp), x$mp3, input$image_size) 
    dev.off()
    
    # Return a list
    list(src = outfile,
         width  = w,
         height = h,
         alt = "trouble loading image")
  }, deleteFile = TRUE)
  
  output$personalize <- renderUI({
    validate(need(x$mp3, 'record/upload an mp3'))
    fluidRow(
      column(9, imageOutput('wave', height = 'auto', width = '90%')),
      column(3, uiOutput('control_panel'))
    )
  })
  
  observeEvent(input$detail, {
    updateSelectInput(session, 'lw', choices = lw_choices(input$detail))
  })
  
  ### DETAILS ###
  
  # track the number of input boxes to render
  counter <- reactiveValues(n = 1)
  
  observeEvent(input$add_btn, {counter$n <- counter$n + 1})
  observeEvent(input$rm_btn, {if (counter$n > 1) counter$n <- counter$n - 1})
  
  output$details <- renderUI({
    lapply(seq_len(counter$n), function(x) render_detail_row(x, input$garment, input$hex))
  })
  
  order_details <- reactive({
    sapply(seq_len(counter$n), function(i) {
      q  = input[[paste0('q', i)]]
      ss = input[[paste0('shirt_size', i)]]
      sc = input[[paste0('shirt_color', i)]]
      paste0('(', paste(q, ss, sc, sep = ' - '),  ')')
    })
  })
  
  total_quantity <- reactive({
    qs = sapply(seq_len(counter$n), function(i) {
      as.numeric(input[[paste0('q', i)]])
    })
    sum(qs)
  })
  
  output$details_card <- renderUI({
    validate(need(x$mp3, 'record/upload an mp3'))
    validate(need(input$hex, 'personalize image'))
    validate(need(input$garment, 'choose garment size'))
    validate(need(input$image_size, 'choose image size'))

    fluidRow(
      p('select color, size, and quantity'),
      fluidRow(
        column(
          8, 
          offset = 2,
          uiOutput('details'),
          p('want this in another size or color?'),
          fluidRow(
            column(6, actionButton('add_btn', NULL, icon = icon('plus'), width = '50%')),
            column(6, actionButton('rm_btn', NULL, icon = icon('minus'), width = '50%'))
          )
        )
      ),
      hr(),
      fluidRow(
        column(
          6, 
          offset = 3,
          fluidRow(
            column(4, actionLink('example', 'samples')),
            column(4, actionLink('size_guide', 'size guide')),
            column(4, actionLink('bundles', 'bundles'))
          )
        )
      )
    )
  })
  
  observeEvent(input$example, {
    showModal(modalDialog(
      title = "samples",
      sample_ligtbox(),
      easyClose = TRUE,
      size = 'l'
    ))
  })
  
  observeEvent(input$size_guide, {
    showModal(modalDialog(
      title = "size guide",
      fluidRow(column(12, align = 'center', img(src = "sizeguide.jpg", width = '80%'))),
      easyClose = TRUE,
      size = 'l'
    ))
  })
  
  observeEvent(input$bundles, {
    showModal(modalDialog(
      title = "bundles",
      fluidRow(column(12, align = 'center', img(src = "discount.jpg", width = '80%'))),
      easyClose = TRUE,
      size = 'l'
    ))
  })
  
  no_null_details <- reactive({
    ad = sapply(seq_len(counter$n), function(i) {
      x = isTruthy(input[[paste0('q', i)]])
      y = isTruthy(input[[paste0('shirt_size', i)]])
      z = isTruthy(input[[paste0('shirt_color', i)]])
      c(x, y, z)
    })
    all(ad)
  })
  
  ### CONFIRMATION ###
  
  output$wave_confirmation <- renderImage({
    validate(need(input$image_size, ''))
    validate(need(x$mp3, ''))
    
    w = session$clientData$output_wave_confirmation_width; h = w*(2/3)
    outfile = tempfile(fileext='.png')
    
    # Generate a png
    png(file = outfile, width = 1200, height = 800, res = 120)
    plot_wave(reactiveValuesToList(pp), x$mp3, input$image_size) 
    dev.off()
    
    # Return a list
    list(src = outfile,
         width  = w,
         height = h,
         alt = "trouble loading image")
  }, deleteFile = TRUE)
  
  output$details_summary <- renderTable({
    lab = paste0(gsub('_', ' ', input$garment), 's', ' (total)')
    y = c(paste(total_quantity(), lab), order_details(), input$image_size)
    x = c('order summary:', rep('', length(y) - 1))
    data.table(x = x, y = y)
  }, align = 'cc', colnames = FALSE, bordered = FALSE, striped = FALSE)
  
  output$checkout <- renderUI({
    validate(need(x$mp3, 'record/upload an mp3'))
    validate(need(input$hex, 'personalize image'))
    validate(need(input$garment, 'choose garment size'))
    validate(need(input$image_size, 'choose image size'))
    validate(need(no_null_details(), 'please fill all fields in "details"'))
    fluidRow(
      fluidRow(
        column(
          8, 
          offset = 2, 
          align = 'center',
          em('heads up, what you see here will be printed.'),
          br(),
          em('what do you want to do?'),
          imageOutput('wave_confirmation', height = 'auto', width = '90%')
        )
      ),
      fluidRow(
        tableOutput('details_summary'),
        column(
          8, 
          offset = 2,
          fluidRow(
            column(6, actionButton('order', "PROCEED TO CHECKOUT")),
            column(6, actionButton('open_personalize', "CONTINUE PERSONALIZING"))
          )
        )
      )
    )
  })
  
  
  
  observeEvent(input$order, {
    fn = plot_wave(reactiveValuesToList(pp), x$mp3, input$image_size, TRUE)
    id = ids[which(input$garment == c('tee', 'hoodie', 'long-sleeve'))]
    js$order(mk_url(fn, order_details(), id, total_quantity(), input$image_size))
  })
  
  observeEvent(input$open_personalize, {
    updateCollapse(session, 'main', open = 'personalize', close = 'review')
  })
  
}

pkgs = c('shiny', 'data.table',  'tuneR', 'colourpicker', 'extrafont', 
         'shinyjs', 'shinyBS')
lapply(pkgs, library, character.only = TRUE); rm(pkgs)

ex <- list(lab = 'hey yo bae', hex = '#1b87e0', det = 'more', fam = 'medium', fl = 1,
           mag = 'large', lw = 'small')

hex_ref <- data.table(web   = c('#1B87E0','#ED635F','#6ABF90','#FF814A','#8369A8','#F4DE5B'),
                      white = c('#489CFF','#FF645C','#52FF80','#E1AF2E','#CD00DD','#FFDF22'),
                      black = c('#0068B1','#FF6464','#52FF80','#E19933','#D970FF','#FFFF2B'))

rm_punct <- function(x) gsub('[[:punct:]]| |.mp3$', '', x)
mk_filename <- function(x) paste(rm_punct(x), collapse = '_')

mk_obj_filename <- function(data) {
  sprintf("%s_%s", as.integer(Sys.time()), digest::digest(data))
}

mk_url <- function(img_file, order_details, q, gs) {
  url_base = paste0('http://amorata.myshopify.com/cart/21393505797:', q, '?')
  file_base = 'http://amorata-apps.com:8787/files/apps/waves/plots/'
  
  img_attr = paste0('attributes[img-file]=', file_base, img_file)
  gs_attr  = paste0('attributes[graphic-size]=', gs)
  od_attr  = paste0('attributes[order-details]=', paste(order_details,  collapse = ' '))
  all_attr = paste(img_attr, gs_attr, od_attr, sep = '&')
  
  paste0(url_base, all_attr)
}

nrs <- function(x) {
  floor(2500/switch(x, 'more'=1, '+1'=7, '0'=15, 'neutral'=30, 'less'=55))
}

set_par <- function(x) {
  if (x != '') par(mar = c(3.5, 0, 0, 0), mgp = c(1.5, 0, 0), bg=NA)
  else par(mar = c(0.0, 0, 0, 0), mgp = c(0, 0, 0), bg=NA)
}

save_wave <- function(rv, mp3) {
  # source("~/apps/waves/src/s3.R", local = TRUE)
  i = 10; w = 300*i; h = w*(2/3)
  new_fn = mk_obj_filename(mp3)
  rv = paste0(new_fn, '.png')
  fn = paste0('~/apps/waves/plots/', rv)
  png(file=fn, width=w, height=h, res=300)
  # s3put(fn, paste0("waves/", fn))
  return(rv)
}

# small_plot(ex, readMP3('~/apps/waves/Adventure.mp3'))
small_plot <- function(rv, mp3, save) {
  # if (save == TRUE) {
  #   sub_dt = hex_ref[web == rv$hex]
  #   hex = ifelse(rv$sc == 'black', sub_dt[,black], sub_dt[,white])
  # } else {
  #   hex = rv$hex
  # }
  
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = 4, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = 4, family = 'Futura Md BT', col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs('less'), lwd = 10)
}

big_plot <- function(rv, mp3, save) {
  # mag = seq(2, 4, (4 - 2)/(5 - 1))[rv$mag]
  # fam = switch(rv$fam, medium = 'Futura Md BT', light = 'Futura Lt BT')
  
  mag = switch(rv$mag, small = 2, medium = 3, large = 4)
  fl  = switch(rv$fl, regular = 1, bold = 2, italic = 3, both = 4)
  lw  = switch(rv$lw, small = 2, medium = 6, large = 10)
  
  # if (save == TRUE) {
  #   sub_dt = hex_ref[web == rv$hex]
  #   hex = ifelse(rv$sc == 'black', sub_dt[,black], sub_dt[,white])
  # } else {
  #   hex = rv$hex
  # }
  
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = mag, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = fl, col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = lw)
}

sample_plot <- function(mp3, img_size) {
  set_par('')
  if (img_size == 'left pocket 3"x1.6"') {
    rv = list(lab = '', hex = '#4c4c4c', det = 'less')
  } else {
    rv = list(lab = '', hex = '#4c4c4c', det = 'more', 
              fam = 'medium', fl = 1, mag = 'small', lw = 'small')
  }
  
  if (img_size == 'left pocket 3"x1.6"') small_plot(rv, mp3)
  if (img_size == 'across chest 11"x6"') big_plot(rv, mp3)
}

plot_wave <- function(rv, mp3, img_size, save = FALSE) {
  set_par(rv$lab)
  if (save == TRUE) {fn = save_wave(rv, mp3)}
  if (img_size == 'left pocket 3"x1.6"') small_plot(rv, mp3, save)
  if (img_size == 'across chest 11"x6"') big_plot(rv, mp3, save)
  if (save == TRUE) {dev.off(); fn}
}

### UI Elements

small_control_panel <- function() {
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
  tags$div(
    fluidRow(column(12, align = 'center',
                    # selectInput('detail', 'wave detail', c('+2','+1','-1','-2')),
                    colourpicker::colourInput('hex',
                                              'select color',
                                              palette = 'limited',
                                              allowedCols = df,
                                              showColour = 'background'),
                    textInput('lab', NULL, value = '', placeholder = 'title (optional)')
    ))
  )
}

big_control_panel <- function() {
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
  tags$div(
    fluidRow(column(12, align = 'center',
                    selectInput('detail', 'wave detail', c('more', 'neutral', 'less')),
                    colourpicker::colourInput('hex',
                                              'select color',
                                              palette = 'limited',
                                              allowedCols = df,
                                              showColour = 'background'),
                    selectInput('lw', 'line thickness', c('small', 'medium', 'large')),
                    textInput('lab', NULL, value = '', placeholder = 'title (optional)'),
                    conditionalPanel(
                      "input.lab !== ''",
                      fluidRow(column(12,
                                      selectInput('fl', 'style', c('regular', 'bold', 'italic', 'both')),
                                      selectInput('mag', 'text size', c('small', 'medium', 'large'))))
                    )
    ))
  )
}

lw_choices <- function(detail) {
  switch(detail,
         more = 'small',
         neutral = c('small', 'medium'), 
         less = c('small', 'medium', 'large'))
}

sample_ligtbox <- function() {
  tags$div(
    fluidRow(
      column(4, align = 'center',
             h4('white'),
             img(src = 'wave-white.jpg', height = '260px')),
      column(4, align = 'center', 
             h4('ash'),
             img(src = 'wave-grey.jpg', height = '260px')),
      column(4, align = 'center',
             h4('black'),
             img(src = 'wave-black.jpg', height = '260px'))
    )
  )
}

selInput <- function(inputId, choices, placeholder) {
  selectizeInput(inputId = inputId, 
                 label = NULL, 
                 choices = choices,
                 options = list(
                   placeholder = placeholder,
                   onInitialize = I('function() { this.setValue(""); }')))
}

render_detail_row <- function(i) {
  shirt_sizes  = c('xs', 's', 'm', 'l', 'xl', 'xxl', 'xxxl')
  shirt_colors = c('white', 'ash', 'black')
  
  renderUI({
    fluidRow(
      column(4, selInput(paste0('shirt_color', i), shirt_colors, 'shirt color')),
      column(4, selInput(paste0('shirt_size', i), shirt_sizes, 'shirt size')),
      column(4, numericInput(paste0('q',i), NULL, 1, 1, step = 1))
    )
  })
}

mic_ui <- renderUI({
  tags$div(
    tags$div(
      id = 'viz',
      HTML("<canvas id=\"analyser\" width=\"0\" height=\"0\"></canvas>
           <canvas id=\"wavedisplay\" width=\"0\" height=\"0\"></canvas>")),
    tags$div(
      id = 'controls',
      HTML("<img id=\"record\" src=\"mic128.png\" onclick=\"toggleRecording(this);\">
           <a id=\"save\" href=\"#\"><img src=\"save.svg\"></a>"))
  )
})

head_html <- tags$head(HTML("
                            <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">
                            
                            <script src=\"js/audiodisplay.js\"></script>
                            <script src=\"js/recorderjs/recorder.js\"></script>
                            <script src=\"js/main.js\"></script>
                            <style>
                            
                            #record { height: 10vh; }
                            #record.recording { 
                            background: red;
                            background: -webkit-radial-gradient(center, ellipse cover, #ff0000 0%,white 75%,white 100%,#7db9e8 100%); 
                            background: -moz-radial-gradient(center, ellipse cover, #ff0000 0%,white 75%,white 100%,#7db9e8 100%); 
                            background: radial-gradient(center, ellipse cover, #ff0000 0%,white 75%,white 100%,#7db9e8 100%); 
                            }
                            #save, #save img { height: 10vh; }
                            #save { opacity: 0.25; display: none;}
                            #save[download] { opacity: 1;}
                            
                            </style>"
                            )
                            )

# http://stackoverflow.com/questions/35783446/can-you-have-an-image-as-a-radiobutton-choice-in-shiny
radioButtons_withHTML <- function (inputId, label, choices, selected = NULL, inline = FALSE, width = NULL) {
  choices <- shiny:::choicesWithNames(choices)
  selected <- if (is.null(selected)) 
    choices[[1]]
  else {
    shiny:::validateSelected(selected, choices, inputId)
  }
  if (length(selected) > 1) 
    stop("The 'selected' argument must be of length 1")
  options <- generateOptions_withHTML(inputId, choices, selected, inline, type = "radio")
  divClass <- "form-group shiny-input-radiogroup shiny-input-container"
  if (inline) 
    divClass <- paste(divClass, "shiny-input-container-inline")
  tags$div(id = inputId, style = if (!is.null(width)) 
    paste0("width: ", validateCssUnit(width), ";"), class = divClass, 
    shiny:::controlLabel(inputId, label), options)
}

generateOptions_withHTML <- function (inputId, choices, selected, inline, type = "checkbox") {
  options <- mapply(choices, names(choices), FUN = function(value, name) {
    inputTag <- tags$input(type = type, name = inputId, value = value)
    if (value %in% selected) 
      inputTag$attribs$checked <- "checked"
    if (inline) {
      tags$label(class = paste0(type, "-inline"), inputTag, 
                 tags$span(HTML(name)))
    }
    else {
      tags$div(class = type, tags$label(inputTag, tags$span(HTML(name))))
    }
  }, SIMPLIFY = FALSE, USE.NAMES = FALSE)
  div(class = "shiny-options-group", options)
}

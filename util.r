pkgs = c('shiny', 'data.table',  'tuneR', 'colourpicker', 'extrafont', 
         'shinyjs', 'shinyBS')
lapply(pkgs, library, character.only = TRUE); rm(pkgs)

lapply(list.files('~/apps/waves/src/', full.names = TRUE), source)

ex <- list(lab = 'hey yo bae', hex = '#FFFFFF', det = 'more', fam = 'medium', fl = 1,
           mag = 'large', lw = 'small')

hex_ref <- data.table(web   = c('#1B87E0','#ED635F','#6ABF90','#FF814A','#8369A8','#F4DE5B'),
                      white = c('#489CFF','#FF645C','#52FF80','#E1AF2E','#CD00DD','#FFDF22'),
                      black = c('#0068B1','#FF6464','#52FF80','#E19933','#D970FF','#FFFF2B'))

mk_filename <- function(data) {
  sprintf("%s_%s", as.integer(Sys.time()), digest::digest(data))
}

mk_url <- function(img_file, order_details, id, q, gs) {
  url_base = paste0('http://amorata.myshopify.com/cart/', id, ':', q, '?')
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
  i = 10; w = 300*i; h = w*(2/3)
  new_fn = mk_filename(mp3)
  rv = paste0(new_fn, '.png')
  fn = paste0('~/apps/waves/plots/', rv)
  png(file=fn, width=w, height=h, res=300)
  return(rv)
}

# small_plot(ex, readMP3('~/apps/waves/Adventure.mp3'))
small_plot <- function(rv, mp3, save) {
  
  if (rv$hex == '#FFFFFF') {par(bg = 'grey')}
  
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = 4, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = 4, family = 'Futura Md BT', col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs('less'), lwd = 10,
       #Background Hack
       bg = ifelse(rv$hex == '#FFFFFF',  'grey', NA))
}

big_plot <- function(rv, mp3, save) {
  # mag = seq(2, 4, (4 - 2)/(5 - 1))[rv$mag]
  # fam = switch(rv$fam, medium = 'Futura Md BT', light = 'Futura Lt BT')
  
  mag = switch(rv$mag, small = 2, medium = 3, large = 4)
  fl  = switch(rv$fl, regular = 1, bold = 2, italic = 3, both = 4)
  lw  = switch(rv$lw, small = 2, medium = 6, large = 10)
  if (rv$hex == '#FFFFFF') {par(bg = 'grey')}
  
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = mag, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = fl, col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = lw,
       #Background Hack
       bg = ifelse(rv$hex == '#FFFFFF',  'grey', NA))
}

# sample_plot <- function(mp3, img_size) {
sample_plot <- function(mp3) {
  set_par('')
  # if (img_size == 'left pocket 3"x1.6"') {
  #   rv = list(lab = '', hex = '#4c4c4c', det = 'less')
  # } else {
  #   rv = list(lab = '', hex = '#4c4c4c', det = 'more', 
  #             fam = 'medium', fl = 1, mag = 'small', lw = 'small')
  # }
  # 
  # if (img_size == 'left pocket 3"x1.6"') small_plot(rv, mp3)
  # if (img_size == 'across chest 11"x6"') big_plot(rv, mp3)
  rv = list(lab = '', hex = '#4c4c4c', det = 'less')
  small_plot(rv, mp3)
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
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b', '#ffffff', '#000000')
  tags$div(
    fluidRow(column(12, align = 'center',
                    colourpicker::colourInput('hex',
                                              'select color',
                                              palette = 'limited',
                                              allowedCols = df,
                                              showColour = 'background',
                                              value = df[5]),
                    # verbatimTextOutput('hex_test'),
                    textInput('lab', NULL, value = '', placeholder = 'title (optional)')
    ))
  )
}

big_control_panel <- function() {
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b', '#ffffff', '#000000')
  tags$div(
    fluidRow(column(12, align = 'center',
                    selectInput('detail', 'wave detail', c('more', 'neutral', 'less'), selected = 'less'),
                    colourpicker::colourInput('hex',
                                              'select color',
                                              palette = 'limited',
                                              allowedCols = df,
                                              showColour = 'background', 
                                              value = df[5]),
                    # verbatimTextOutput('hex_test'),
                    selectInput('lw', 'line thickness', c('large', 'medium', 'small')),
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
         neutral = c('medium', 'small'), 
         less = c('large', 'medium', 'small'))
}

selInput <- function(inputId, choices, placeholder) {
  selectizeInput(inputId = inputId, 
                 label = NULL, 
                 choices = choices,
                 options = list(
                   placeholder = placeholder,
                   onInitialize = I('function() { this.setValue(""); }')))
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

head_html <- tags$head(
   HTML("
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0\"/>
        
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

##############################

selInput <- function(inputId, choices, placeholder) {
  selectizeInput(inputId = inputId, 
                 label = NULL, 
                 choices = choices,
                 options = list(
                   placeholder = placeholder,
                   onInitialize = I('function() { this.setValue(""); }')))
}

render_detail_row <- function(i, garment, hex) {
  shirt_sizes  = switch(garment,
                        tee = c('xs', 's', 'm', 'l', 'xl', 'xxl', 'xxxl'),
                        hoodie = c('xs', 's', 'm', 'l', 'xl', 'xxl'),
                        'long-sleeve' = c('s', 'm', 'l', 'xl', 'xxl'))
  shirt_colors = switch(garment,
                        tee = c('white', 'ash', 'heather grey', 'black'),
                        hoodie = c('white', 'heather grey', 'black'),
                        'long-sleeve' = c('white', 'black'))
  
  if (hex == '#FFFFFF') {shirt_colors = shirt_colors[!(shirt_colors %in% c('white',  'ash'))]}
  if (hex == '#000000') {shirt_colors = shirt_colors[shirt_colors != 'black']}
  if (hex == '#F4DE5B') {shirt_colors = shirt_colors[shirt_colors != 'white']}
  
  renderUI({
    fluidRow(
      column(4, selInput(paste0('shirt_color', i), shirt_colors, 'garmet color')),
      column(4, selInput(paste0('shirt_size', i), shirt_sizes, 'garment size')),
      column(4, numericInput(paste0('q',i), NULL, 1, 1, step = 1))
    )
  })
}

intro_card <- function(img_file) {
  bsCollapsePanel(
    'intro',
    img(src = img_file, 
        align = 'center', 
        width = '100%', 
        height = 'auto')
  )
}

garment_card <- function(inputId, choices) {
  bsCollapsePanel(
    'garment type',
    p('select garment type (tee, hoodie, long sleeve)'),
    radioButtons_withHTML(inputId, 
                          NULL, 
                          choices = choices, 
                          inline = FALSE)
  )
}

image_size_card <- function(inputId, choices) {
  bsCollapsePanel(
    'graphic size',
    p('select between an across the chest graphic (11"x6") or a left pocket icon (3"x1.6")'),
    radioButtons_withHTML(inputId, 
                          NULL, 
                          choices = choices, 
                          inline = FALSE)
  )
}

sample_ligtbox <- function() {
  tags$div(
    fluidRow(
      lapply(list.files('~/apps/waves/www/samples/'), function(x) {
        column(4, align = 'center', img(src = paste0('samples/', x), height = '260px'))
      })
    )
  )
}

pkgs = c('shiny', 'data.table',  'tuneR', 
         'colourpicker', 'extrafont', 'shinyjs')
lapply(pkgs, library, character.only = TRUE); rm(pkgs)

ex <- list(lab = 'yoo', hex = '#6784A9', det = '+1', fam = 'Medium', fl = 1,
           mag = 3, lw = 3, is = 'Left Pocket (3X2)', ss = 'M', sc = 'Black',
           mp3 = list(datapath = '~/apps/waves/Adventure.mp3', name = 'Aventure.mp3'))

mk_obj_filename <- function(data) {
# Sys.time() <- as.POSIXct(as.integer(Sys.time()), origin="1970-01-01")
  sprintf("%s_%s", as.integer(Sys.time()), digest::digest(data))
}
rm_punct <- function(x) gsub('[[:punct:]]| |.mp3$', '', x)
mk_filename <- function(x) paste(rm_punct(x), collapse = '_')

mk_url <- function(img_file, ss, sc, gs) {
  url_base = 'http://amorata.myshopify.com/cart/21393505797:1?'
  file_base = 'http://amorata-dev.com:8787/files/apps/waves/plots/'
  
  img_attr = paste0('attributes[img-file]=', file_base, img_file)
  ss_attr = paste0('attributes[shirt-size]=', ss)
  sc_attr = paste0('attributes[shirt-color]=', sc)
  gs_attr = paste0('attributes[graphic-size]=', gs)
  
  all_attr = paste(img_attr, ss_attr, sc_attr, gs_attr, sep = '&')
  
  paste0(url_base, all_attr)
}

# mk_url <- function(x) {
#   url_base = 'http://amorata.myshopify.com/cart/21393505797:1?note='
#   pattern = '~/apps/waves/plots/|.png'
#   paste0(url_base, gsub(pattern, '', x))
# }

nrs <- function(x) {
  floor(2500/switch(x, '+2'=1, '+1'=7, '0'=15, '-1'=30, '-2'=55))
}

set_par <- function(x) {
  if (x != '') par(mar = c(3.1, 0, 0, 0), mgp = c(1, 0, 0), bg=NA)
  else par(mar = c(0.0, 0, 0, 0), mgp = c(0, 0, 0), bg=NA)
}

save_wave <- function(rv, mp3) {
  i = 10; w = 300*i; h = w*(2/3)
  new_fn = mk_obj_filename(mp3)
  rv = paste0(new_fn, '.png')
  fn = paste0('~/apps/waves/plots/', rv)
  png(file=fn, width=w, height=h, res=300)
  return(rv)
}

small_plot <- function(rv, mp3) {
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = 4, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = 4, family = 'Futura Md BT', col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = (3-as.numeric(rv$det))*2)
}

big_plot <- function(rv, mp3) {
  mag = seq(2, 4, (4 - 2)/(5 - 1))[rv$mag]
  fam = switch(rv$fam, medium = 'Futura Md BT', light = 'Futura Lt BT')
  fl  = switch(rv$fl, regular = 1, bold = 2, italic = 3, both = 4)
  
  plot(mono(mp3), 
       #Label Options
       xlab = rv$lab, cex.lab = mag, axes = FALSE, ylab = '', 
       #Text Options
       font.lab = fl, family = fam, col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = rv$lw)
}

plot_wave <- function(rv, mp3, img_size, save = FALSE) {
  set_par(rv$lab)
  if (save == TRUE) {fn = save_wave(rv, mp3)}
  if (img_size == 'left pocket 3"x1.6"') small_plot(rv, mp3)
  if (img_size == 'across chest 11"x6"') big_plot(rv, mp3)
  if (save == TRUE) {dev.off(); fn}
}

### UI Elements

small_control_panel <- function() {
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
  tags$div(
    fluidRow(column(12, align = 'center',
       selectInput('detail', 'wave detail', c('+2','+1','-1','-2')),
       colourpicker::colourInput('hex',
                                 'color',
                                 palette = 'limited',
                                 allowedCols = df,
                                 showColour = 'background'),
       textInput('lab', 'title', value = '', placeholder = '(optional)')
    ))
  )
}

big_control_panel <- function() {
  df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
  tags$div(
    fluidRow(column(12, align = 'center',
      selectInput('detail', 'wave detail', c('+2','+1','0','-1','-2')),
      colourInput('hex',
                  'color',
                  palette = 'limited',
                  allowedCols = df,
                  showColour = 'background'),
      sliderInput('lw', 'line thickness', 1, 10, 1, 1),
      textInput('lab', 'title', value = '', placeholder = '(optional)'),
      conditionalPanel(
        "input.lab !== ''",
        fluidRow(
          selectInput('fam', 'font', c('light', 'medium')),
          selectInput('fl', 'style', c('regular', 'bold', 'italic', 'both')),
          sliderInput('mag', 'text size', 1, 5, 1, 1))
      )
    ))
  )
}

sample_ligtbox <- function() {
  tags$div(
    fluidRow(
      column(6, 
        h4('white'),
        img(src = 'mockup-7c89c719_1024x1024.png', height = '200px'),
        h4('heather grey'),
        img(src = 'mockup-a6917a09_1024x1024.png', height = '200px')),
      column(6, 
        h4('ash'),
        img(src = 'mockup-6505a0fc_1024x1024.png', height = '200px'),
        h4('black'),
        img(src = 'mockup-50a57144_1024x1024.png', height = '200px'))
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

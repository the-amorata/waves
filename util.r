pkgs = c('shiny', 'data.table',  'tuneR', 
         'colourpicker', 'extrafont', 'shinyjs')
lapply(pkgs, library, character.only = TRUE); rm(pkgs)

# ex <- list(lab = 'yoo', hex = '#6784A9', det = '+1', fam = 'Medium', fl = 1, 
#            mag = 3, lw = 3, is = 'Left Pocket (3X2)', ss = 'M', sc = 'Black',
#            mp3 = list(datapath = '~/ShinyApps/waves-dev/Adventure.mp3', name = 'Aventure.mp3'))

rm_punct <- function(x) gsub('[[:punct:]]| |.mp3$', '', x)
mk_filename <- function(x) paste(rm_punct(x), collapse = '_')

mk_url <- function(x) {
  url_base = 'http://amorata.myshopify.com/cart/21393505797:1?note='
  pattern = '~/ShinyApps/waves-dev/plots/|.png'
  paste0(url_base, gsub(pattern, '', x))
}

nrs <- function(x) {
  floor(2500/switch(x, '+2'=1, '+1'=7, '0'=15, '-1'=30, '-2'=55))
}

set_par <- function(x) {
  if (x != '') par(mar = c(3.1, 0, 0, 0), mgp = c(1, 0, 0), bg=NA)
  else par(mar = c(0.0, 0, 0, 0), mgp = c(0, 0, 0), bg=NA)
}

save_wave <- function(rv) {
  i = 10; w = 300*i; h = w*(2/3)
  new_fn = mk_filename(c((rv$mp3)$name, Sys.time(), rv$ss, rv$is, rv$sc))
  fn = paste0('~/ShinyApps/waves-dev/plots/', new_fn, '.png')
  png(file=fn, width=w, height=h, res=300)
  return(fn)
}

small_plot <- function(rv) {
  plot(mono(readMP3((rv$mp3)$datapath)), 
       #Label Options
       xlab = rv$lab, cex.lab = 4, axes=FALSE, ylab='', 
       #Text Options
       font.lab = 4, family = 'Futura Md BT', col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = (3-as.numeric(rv$det))*2)
}

big_plot <- function(rv) {
  mag = seq(2, 4, (4 - 2)/(5 - 1))[rv$mag]
  fam = switch(rv$fam, Medium = 'Futura Md BT', Light = 'Futura Lt BT')
  fl  = switch(rv$fl, Regular = 1, Bold = 2, Italic = 3, Both = 4)
  
  plot(mono(readMP3((rv$mp3)$datapath)), 
       #Label Options
       xlab = rv$lab, cex.lab = mag, axes=FALSE, ylab='', 
       #Text Options
       font.lab = fl, family = fam, col.lab = rv$hex,
       #Line Options
       col = rv$hex, nr = nrs(rv$det), lwd = rv$lw)
}

plot_wave <- function(rv, save = FALSE) {
  set_par(rv$lab)
  if (save == TRUE) {fn = save_wave(rv)}
  if (rv$is == 'Left Pocket (3X2)') small_plot(rv)
  if (rv$is == 'Across Chest (10X12)') big_plot(rv)
  if (save == TRUE) {dev.off(); fn}
}

### UI Elements

small_control_panel <- function() {
  df = c('#6784A9','#96CDC2','#F58C8D','#BC94C1','#C27186','#E7D49F')
  tags$div(
    fluidRow(
      column(6,
        selectInput('detail', 'Wave Detail', c('+2','+1','-1','-2'))),
      column(6,
        colourInput('hex',
                    'Color',
                    palette = 'limited',
                    allowedCols = df,
                    showColour = 'background'))
    ),
    fluidRow(
      column(6,
        textInput('lab', 'Title', value = '', placeholder = '(Optional)'))
    )
  )
}

big_control_panel <- function() {
  df = c('#6784A9','#96CDC2','#F58C8D','#BC94C1','#C27186','#E7D49F')
  tags$div(
    fluidRow(
      column(3,
        selectInput('detail', 'Wave Detail', c('+2','+1','0','-1','-2'))),
      column(3,
        colourInput('hex',
                    'Color',
                    palette = 'limited',
                    allowedCols = df,
                    showColour = 'background')),
      column(6,
        sliderInput('lw', 'Line Thickness', 1, 10, 1, 1))
    ),
    fluidRow(
      column(6,
        textInput('lab', 'Title', value = '', placeholder = '(Optional)'))
    ),
    conditionalPanel(
      "input.lab !== ''",
      fluidRow(
        column(3,
          selectInput('fam', 'Font', c('Light', 'Medium'))),
        column(3,
          selectInput('fl', 'Style', c('Regular', 'Bold', 'Italic', 'Both'))),
        column(6,
          sliderInput('mag', 'Text Size', 1, 5, 1, 1))
      ))
  ) 
}

sample_ligtbox <- function() {
  tags$div(
    fluidRow(
      column(6, 
        h4('White'),
        img(src = 'mockup-7c89c719_1024x1024.png', height = '200px'),
        h4('Heather Grey'),
        img(src = 'mockup-a6917a09_1024x1024.png', height = '200px')),
      column(6, 
        h4('Ash'),
        img(src = 'mockup-6505a0fc_1024x1024.png', height = '200px'),
        h4('Black'),
        img(src = 'mockup-50a57144_1024x1024.png', height = '200px'))
    )
  )
}

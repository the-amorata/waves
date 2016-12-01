source("~/apps/waves/util.r")

df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
waves_id = 21393505797
shirt_sizes  = c('xs','s','m', 'l', 'xxl', 'xxxl')
shirt_colors = c('white','ash','heather grey', 'black')
image_sizes  = c('left pocket 3"x1.6"', 'across chest 11"x6"')

jsCode <- "
  shinyjs.order = function(params) {
    //console.log(params[0]);
    window.location.href = params[0];
  }"

fluidPage(
  title = 'W A V E S',
  theme = "adjust.css",
  
  useShinyjs(),
  extendShinyjs(text = jsCode, functions = c('order')),
  head_html, 
  
  fluidRow(
    column(3, align = 'center',
      fluidRow(column(12, 
        h1('W A V E S'),
        selInput('image_size',  image_sizes, 'choose graphic size'),
        uiOutput('mic')
      )),
      
      uiOutput('control_panel'),
      
      fluidRow(column(12, align = 'center',
        selInput('shirt_size',  shirt_sizes, 'shirt size'),
        selInput('shirt_color', shirt_colors, 'shirt color')
      )),
      fluidRow(column(12, align = 'center',
        actionLink('example', 'samples'), br(),
        uiOutput('button')
      )),
      hr(),
      helpText(
        'comments, questions, issues?',
        a('info@amoratadesigns.com', href = 'mailto:info@amoratadesigns.com'),
        br(),
        em('this visualization only works on desktop')
      )
    ),
    column(9, align = 'center',
      plotOutput('wave', height = 'auto', width = '90%')
    )
  )
)
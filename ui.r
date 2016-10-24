source("~/apps/waves/util.r")

df = c('#6784A9','#96CDC2','#F58C8D','#BC94C1','#C27186','#E7D49F')
waves_id = 21393505797
shirt_sizes  = c('', 'XS','S','M', 'L', '2XL', '3XL')
shirt_colors = c('', 'White','Ash','Heather Grey', 'Black')
image_sizes  = c('', 'Left Pocket (3X2)', 'Across Chest (10X12)')

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
  
  fluidRow(
    column(4,
      fluidRow(column(12, h1('W A V E S'))),
      fluidRow(
        column(6,
          selectInput('image_size',  'Choose A Product',  image_sizes)),
        column(6,
          fileInput('mp3', 
                    'Upload An MP3 File', 
                    accept=c('audio/mp3', '.mp3')))
      ),
      
      uiOutput('control_panel'),
      
      fluidRow(
        column(6, selectInput('shirt_size',  'Shirt Size:',  shirt_sizes)),
        column(6, selectInput('shirt_color', 'Shirt Color:', shirt_colors))
      ),
      fluidRow(
        column(8, uiOutput('button')),
        column(4, actionLink('example', 'Samples'))
      ),
      hr(),
      helpText(
        "Don't have an MP3?",
        a("Use a YouTube video", 
          href = 'http://www.youtube-mp3.org/',
          target='_blank'),
        br(),
        'File not an MP3?', 
        a("Convert it.", 
          href='http://audio.online-convert.com/convert-to-mp3', 
          target="_blank"), 
        br(),
        'Comments, Questions, Issues?',
        a('info@amoratadesigns.com', href = 'mailto:info@amoratadesigns.com'),
        br(),
        em('*This site currently only works on desktop. Mobile coming soon.')
      )
    ),
    column(8, align = 'center',
      plotOutput('wave', height = 'auto', width = '90%')
    )
  )
)
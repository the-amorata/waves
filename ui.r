source("~/apps/waves/util.r")

df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b', '#FFFFFF', '#000000')
ids = c('21393505797', '24373225925', '24373305733')
image_sizes  = c('<img src="graphic-size/across-the-chest.jpg">' = 'across chest 11"x6"', 
                 '<img src="graphic-size/left-pocket.jpg">' = 'left pocket 3"x1.6"')
garments  = c('<img src="garment-type/tee.jpg">' = 'tee',
              '<img src="garment-type/hoodie.jpg">' = 'hoodie', 
              '<img src="garment-type/long-sleeve.jpg">' = 'long-sleeve')

jsCode <- "shinyjs.order = function(params) {window.location.href = params[0];}"

fluidPage(
  
  title = 'W A V E S',
  theme = "adjust.css",
  
  useShinyjs(),
  extendShinyjs(text = jsCode, functions = c('order')),
  head_html,
  
  fluidRow(
    column(
      8, 
      offset = 2, 
      align = 'center',
           
      h1('W A V E S'),
      
      bsCollapse(
        id = "main", 
        open = "intro",
        
        intro_card('banner.jpg'),
        
        bsCollapsePanel(
          'create',
          tabsetPanel(
            tabPanel(
              'record',
              fluidRow(
                imageOutput('sample_wave', height = 'auto', width = '60%'),
                br(), 
                p('press mic to begin recording'),
                uiOutput('mic')
              )
            ),
            tabPanel(
              'upload', 
              br(),
              p('someday soon')
            )
          )
        ),
        
        garment_card('garment', garments),
        image_size_card('image_size', image_sizes),
        bsCollapsePanel('personalize', uiOutput('personalize')),
        bsCollapsePanel('details', uiOutput('details_card')),
        bsCollapsePanel('review', uiOutput('checkout'))
      ), # end of bsCollapse
      helpText(
        'comments/questions?', 
        a('contact amorata', href = 'mailto:info@amoratadesigns.com')
      )
    ) # end of centering column
  ) # end of main fluidRow
) # end of everything

source("~/apps/waves/util.r")

df = c('#1b87e0','#ed635f','#6abf90','#ff814a','#8369a8','#f4de5b')
waves_id = 21393505797
shirt_sizes  = c('xs', 's', 'm', 'l', 'xl', 'xxl', 'xxxl')
shirt_colors = c('white', 'ash', 'black')
image_sizes  = c('<img src="gs_ac.jpg">' = 'across chest 11"x6"', '<img src="gs_lp.jpg">' = 'left pocket 3"x1.6"')

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
    column(8, offset = 2, align = 'center',
           h1('W A V E S'),
           bsCollapse(id = "main", open = "intro",
                      bsCollapsePanel('intro',
                                      img(src = 'eddie-intro3.jpg', align = 'center', width = '100%', height = 'auto')
                      ),
                      bsCollapsePanel('1. graphic size',
                                      p('select between an across the chest graphic (11"x6") or a left pocket icon (3"x1.6")'),
                                      radioButtons_withHTML('image_size', NULL, choices = image_sizes, inline = TRUE)
                      ),
                      bsCollapsePanel('2. create',
                                      tabsetPanel(
                                        tabPanel('record',
                                                 fluidRow(
                                                   imageOutput('sample_wave', height = 'auto', width = '60%'),
                                                   br(), p('press mic to begin recording'),
                                                   uiOutput('mic')
                                                 )
                                        ),
                                        tabPanel('upload', 
                                                 br(),
                                                 p('someday soon'))
                                      )
                      ),
                      bsCollapsePanel('3. personalize', uiOutput('personalize')),
                      bsCollapsePanel('4. details', uiOutput('details_card')),
                      bsCollapsePanel('review', uiOutput('checkout'))
           ),
           helpText(
             'comments/questions?', 
             a('contact amorata', href = 'mailto:info@amoratadesigns.com')
           )
    )
  )
)
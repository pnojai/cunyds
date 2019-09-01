install.packages(c('openintro','OIdata','devtools','ggplot2','psych','reshape2',
                   'knitr','markdown','shiny','R.rsp'))
devtools::install_github("jbryer/DATA606")

install.packages('tinytex')
tinytex::install_tinytex()

# The DATA606 R Package 

# Many of the course resouces are available in the DATA606 R package.
# Here are some command to get started:
        
library('DATA606')          # Load the package
vignette(package='DATA606') # Lists vignettes in the DATA606 package
vignette('os3')             # Loads a PDF of the OpenIntro Statistics book
data(package='DATA606')     # Lists data available in the package
getLabs()                   # Returns a list of the available labs
viewLab('Lab0')             # Opens Lab0 in the default web browser
startLab('Lab0')            # Starts Lab0 (copies to getwd()), opens the Rmd file
shiny_demo()                # Lists available Shiny apps
demo(package='DATA606')     # Lists available demos

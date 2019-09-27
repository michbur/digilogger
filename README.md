![digilogger](https://github.com/michbur/digilogger/tree/master/inst/digilogger_gui/www/logo.png)
====
Analysis, visualisation and simulation of POCT experiments.

# Installation

*digilogger* is available as the latest development version of the code by using the `devtools` R package.

# Requirements

The *digilogger* software requires a functional R environment (verion 3.5 or later) and a working 
installation of the *shiny* package.

```R
# Start R
# Install devtools, if you haven't already.
install.packages("devtools")

devtools::install_github("michbur/digilogger")
```

# digilogger - standalone graphical user interface

Our digilogger standalone graphical user interface allows the analysis of dPCR data without installing the package on a server. Since the *digilogger* software is based on modern web technologies like HTML5 it will run on any modern web browser. Additionally, the software works when run in [RStudio](https://rstudio.com/products/rstudio/) or [RKWard](https://rkward.kde.org/) (version 0.7.0z+0.7.1+devel1). The *digilogger* software works platform independent (tested on Linux and Windows). 

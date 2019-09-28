![digilogger](https://github.com/michbur/digilogger/tree/master/inst/digilogger_gui/www/logo.png)
====
Analysis, visualisation and simulation of POCT experiments.

# Installation

*digilogger* is available as the latest development version of the code by using the `devtools` R package.

# Requirements

You can install the latest development version of the package:

```R
source("https://install-github.me/michbur/digilogger")
```

After installation GUI can be accessed locally:

```R
library(digilogger)
digilogger_gui()
```

# digilogger - standalone graphical user interface

Our digilogger standalone graphical user interface allows the analysis of dPCR data without installing the package on a server. Since the *digilogger* software is based on modern web technologies like HTML5 it will run on any modern web browser. Additionally, the software works when run in [RStudio](https://rstudio.com/products/rstudio/) or [RKWard](https://rkward.kde.org/) (version 0.7.0z+0.7.1+devel1). The *digilogger* software works platform independent (tested on Linux and Windows). 

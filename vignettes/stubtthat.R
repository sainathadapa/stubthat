## ----include=FALSE-------------------------------------------------------
library('stubthat')

## ------------------------------------------------------------------------
jedi_or_sith <- function(x) return('No one')
stub_builder <- stub(jedi_or_sith)

## ------------------------------------------------------------------------
stub_builder$withArgs(x = 'Luke')$returns('Jedi')

## ----results='asis'------------------------------------------------------
stub_of_fun <- stub_builder$build()

## ------------------------------------------------------------------------
jedi_or_sith('Luke')
stub_of_fun('Luke')


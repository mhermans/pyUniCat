setwd('/home/mhermans/projects/experimental/pyUniCat')
library(ggplot2)
library(reshape)
  
#e <- subset(d, year > 1939 & year < 2011)
#e$integratie <- NULL
#e$multicultur_ <- e$multiculturaliteit + e$multicultureel
#e$multiculturaliteit <- e$multicultureel <- NULL
#e$im_migratie <- e$migratie + e$immigratie
#e$migratie <- e$immigratie <- NULL

stack.plot <- function(filename) {
  X <- read.csv(filename)
  X <- subset(X, year > 1939 & year < 2011)
  X <- melt(X, id='year')
  X <- data.frame(X)
  names(X) <- c('year', 'term', 'count')

  q <- ggplot(X, aes(x=year, y=count, group=term))
  #q + geom_line()
  q <- q + geom_area(aes(colour = term, fill= term), position = 'stack')
  q 
}

vp.layout <- function(x, y) viewport(layout.pos.row=x, layout.pos.col=y)
plot.arrange <- function(..., nrow=NULL, ncol=NULL, as.table=FALSE) {
 dots <- list(...)
 n <- length(dots)
 if(is.null(nrow) & is.null(ncol)) { nrow = floor(n/2) ; ncol = ceiling(n/nrow)}
 if(is.null(nrow)) { nrow = ceiling(n/ncol)}
 if(is.null(ncol)) { ncol = ceiling(n/nrow)}
        ## NOTE see n2mfrow in grDevices for possible alternative
grid.newpage()
pushViewport(viewport(layout=grid.layout(nrow,ncol) ) )
 ii.p <- 1
 for(ii.row in seq(1, nrow)){
 ii.table.row <- ii.row
 if(as.table) {ii.table.row <- nrow - ii.table.row + 1}
  for(ii.col in seq(1, ncol)){
   ii.table <- ii.p
   if(ii.p > n) break
   print(dots[[ii.table]], vp=vp.layout(ii.table.row, ii.col))
   ii.p <- ii.p + 1
  }
 }
}

prog.plot <- stack.plot('datasets/prog.csv')
allo.plot <- stack.plot('datasets/allo.csv')
auth.plot <- stack.plot('datasets/auth.csv')
ineq.plot <- stack.plot('datasets/ineq.csv')

plot.arrange(auth.plot, allo.plot, ineq.plot, prog.plot, ncol=2)
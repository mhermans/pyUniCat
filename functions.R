library(ggplot2)
library(reshape)

normalize_volume <- function(timeserie, maxpoint=100) {
  timeserie/max(timeserie)*maxpoint
}

stack.dataset <- function(data, norm=TRUE) {
  if (norm) {
    data[,!(names(data) == 'year')] <- 
      sapply(data[,!(names(data) == 'year')], normalize_volume) 
  }
  data <- melt(data, id='year')
  data <- data.frame(data)
  names(data) <- c('year', 'term', 'count')
  data
}

plot.trendlines <- function(data, title="") {
  q <- ggplot(data, aes(x=year))
  q <- q + geom_line(aes(y=count, group=term, color=term)) 
  if (length(title) > 0) {
    q <- q + opts(title = title)
  }
  q
}

plot.areas <- function(data) {
  p <- ggplot(data, aes(x=year, y=count, group=term))
  p <- p + geom_area(aes(colour=term, fill=term), position = 'stack')
  p
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
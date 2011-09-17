setwd('/home/mhermans/projects/experimental/pyUniCat')
library(ggplot2)
library(reshape)
  
stack.dataset <- function(data) {
  data <- melt(data, id='year')
  data <- data.frame(data)
  names(data) <- c('year', 'term', 'count')
  data
}

plot.trendlines <- function(data) {
  q <- ggplot(X, aes(x=year))
  q  + geom_line(aes(y=count, group=term, color=term)) 
  q
}

plot.areas <- function(data) {
  p + geom_area(aes(colour = term, fill= term), position = 'stack')
  p <- ggplot(X, aes(x=year, y=count, group=term))
  p
}

#X <- subset(X, year > 1939 & year < 2011)


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

####################
# PLOT DISCIPLINES #
####################

total <- read.csv('datasets/disciplines.csv')
total <- subset(total, year < 2009)

sum(colSums(total)[3:9])
colSums(total)['total']
sum(colSums(total)[3:9])/colSums(total)['total'] #5%

f <- max(c(total$sociologie, total$economie, total$geschiedenis))/max(total$total)
total$total <- total$total*f



total[,-c(1,2)] <- total[,-c(1,2)]/total[,2]*100
total$total <- NULL

allo <- read.csv('datasets/allo.csv')
prog <- read.csv('datasets/prog.csv')
discp <- read.csv('datasets/disciplines.csv')
ineq <- read.csv('datasets/ineq.csv')
migranten <- allo$migranten/max(allo$migranten)*100
minderheden <- allo$minderheden/max(allo$minderheden)*100
marx <- prog$marx/max(prog$marx)*100
stratificatie <- ineq$stratificatie/max(ineq$stratificatie)*100
armoede <-ineq$armoede/max(ineq$armoede)*100
sociologie <- discp$sociologie/max(discp$sociologie)*100
total <- discp$total/max(discp$total)*100
comb <- cbind(migranten, marx, sociologie, total)
comb <- cbind(minderheden, marx, sociologie, total)
comb <- cbind(migranten, armoede, sociologie, total)
comb <- cbind(migranten, stratificatie, sociologie, total) #!
comb <- cbind(armoede, stratificatie, sociologie, total) #!
X <- comb

allo[,-1] <- allo[,-1]/total$sociologie*100
X <- allo
stack.plot('datasets/vs_eu.csv')
setwd('/home/mhermans/projects/experimental/pyUniCat')
source('functions.R')

# ######### #
# BLOG POST #
# ######### #

blogp <- read.csv('datasets/blogpost.csv')
blogp$total <- read.csv('datasets/disciplines.csv')$total
blogp <- subset(blogp, year > 1939)

plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'migranten')]))

plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'armoede')]))

plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'ongelijkheid')]))

plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'ongelijkheid')]))



# taalverschillen?
plot.trendlines(stack.dataset(blogp[,c('year', 'stratificatie', 'stratification')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'ongelijkheid', 'inequality')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'poverty', 'armoede')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'migranten', 'migrants')])) #!

soc <- read.csv('datasets/sociologie_nl.csv')
soc$soc_nl <- soc$sociologie
soc$soc_fr <- read.csv('datasets/sociologie_fr.csv')$sociologie
soc$soc_en <- read.csv('datasets/sociologie_en.csv')$sociologie
soc$soc_ge <- read.csv('datasets/sociologie_ge.csv')$sociologie
soc$soc <- read.csv('datasets/disciplines.csv')$sociologie
soc$soc_sum <- soc$soc_nl + soc$soc_fr + soc$soc_en + soc$soc_ge
soc$sociologie <- NULL
plot.trendlines(stack.dataset(soc, FALSE))
plot.trendlines(stack.dataset(soc, TRUE))
plot.areas(stack.dataset(soc))
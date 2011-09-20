setwd('/home/mhermans/projects/experimental/pyUniCat')
source('functions.R')

# ######### #
# BLOG POST #
# ######### #

blogp <- read.csv('datasets/blogpost.csv')
blogp$total <- read.csv('datasets/disciplines.csv')$total
blogp <- subset(blogp, year > 1939)

# Fig. 1
plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'armoede')]))

# Fig. 2 Plot stratificatie-migranten
plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'migranten')]),
    "Fig. 2: Stratificatie en migranten")

# Fig 3 Plot trends terrorisme, absolute aantallen
plot.trendlines(stack.dataset(
    blogp[,c('year', 'terrorisme', 'migranten', 'minderheden')], F),
    'Fig. 3: Terrorisme en migrantenproblematiek')



plot.trendlines(stack.dataset(
    blogp[,c('year', 'stratificatie', 'migranten', 'minderheden')], T))
      
plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'ongelijkheid')]))

plot.trendlines(stack.dataset(
    blogp[,c('year', 'sociologie', 'stratificatie', 'ongelijkheid')]))

# ########### #
# DISCIPLINES #
# ########### #

dis <- read.csv('datasets/disciplines.csv')
# Fig 4: absolute freq. disciplines
plot.trendlines(stack.dataset(
  dis[,c('year', 'sociologie', 'economie', 'geschiedenis', 
         'management', 'psychologie')], F), 
          'Fig. 4: Evolutie disciplines 1900-2010')


plot.areas(stack.dataset(
  dis[,c('year', 'sociologie', 'economie', 'geschiedenis', 
         'management', 'psychologie')], FALSE))

# ######### #
# CONTROLES #
# ######### #

# taalverschillen?
plot.trendlines(stack.dataset(blogp[,c('year', 'stratificatie', 'stratification')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'ongelijkheid', 'inequality')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'poverty', 'armoede')]))
plot.trendlines(stack.dataset(blogp[,c('year', 'migranten', 'migrants')])) #!

soc <- read.csv('datasets/sociologie_nl.csv')
soc$sociologie_nl <- soc$sociologie
soc$sociologie_fr <- read.csv('datasets/sociologie_fr.csv')$sociologie
soc$sociologie_en <- read.csv('datasets/sociologie_en.csv')$sociologie
soc$sociologie_ge <- read.csv('datasets/sociologie_ge.csv')$sociologie
soc$sociologie_total <- read.csv('datasets/disciplines.csv')$sociologie
soc$sociologie_sum <- soc$sociologie_nl + 
  soc$sociologie_fr + soc$sociologie_en + soc$sociologie_ge
soc$sociologie <- NULL
plot.trendlines(stack.dataset(soc, FALSE)) #!
#plot.trendlines(stack.dataset(soc, TRUE))
#plot.areas(stack.dataset(soc))

# Enkel nederlandstalige "sociologie"
soc_dutch <- cbind(year=blogp$year, 
           sociologie=subset(soc, year > 1939)$sociologie_nl, 
           stratificatie=blogp$stratificatie, 
           migranten=blogp$migranten)

plot.trendlines(stack.dataset(data.frame(soc_dutch), T))

# ############ #                   
# TOTAAL TALEN #
# ############ #
                  
total_langs <- read.csv('datasets/total_dut.csv')
total_langs$dut <- total_langs$None            
total_langs$None <- NULL
total_langs$fre <- read.csv('datasets/total_fre.csv')$None
total_langs$eng <- read.csv('datasets/total_eng.csv')$None
total_langs$ger <- read.csv('datasets/total_ger.csv')$None
total_langs$lat <- read.csv('datasets/total_lat.csv')$None                   
total_langs$spa <- read.csv('datasets/total_spa.csv')$None                   
total_langs$ita <- read.csv('datasets/total_ita.csv')$None
#total_langs$total <- read.csv('datasets/disciplines.csv')$total
plot.trendlines(stack.dataset(data.frame(total_langs), T))
plot.areas(stack.dataset(data.frame(
  total_langs[total_langs$year < 2008,c('year', 'dut', 'fre', 'eng', 'ger')]), F))
                   #plot.areas(stack.dataset(soc))                   
                   
grand_total <- read.csv('datasets/total_1001_2014.csv')
l <- plot.trendlines(stack.dataset(grand_total[grand_total$year %in% 1500:2008,],F))
#l + scale_y_log10()                   
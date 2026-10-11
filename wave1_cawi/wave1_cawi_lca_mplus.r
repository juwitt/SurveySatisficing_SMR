# #_______________________________________________________________________________

# Wave 1 CAWI
#
# Fits LCA models with 1-6 classes for the wave-1 CAWI subsample via
# misty/MplusAutomation and creates the AIC/BIC/aBIC elbow plot.
# Input data: ../waves_dummies_sample.RData (built in Satisficing1_RR.qmd)




rm(list = ls())

if(!require(pacman)){
  install.packages("pacman", dependencies = TRUE)
}
library(pacman)
p_load("tidyverse",  
       "misty",
       "MplusAutomation"
)

# Load data

load(file = "../waves_dummies_sample.RData")
# misty: register the data source for mplus.lca() below
setsource()


# shorter alias of the loaded data
dummies_sample <- waves_dummies_Sample


dummies_sample |> 
  select(pid, hid, contains("Interviewmode"), 
         contains("Particip"), AGET1:NDSO3) |> 
  names()
# [1] "pid"                "hid"                "Interviewmode_w1"
# [4] "Interviewmode_w2" "Interviewmode_w3"   "Participation_w2"
# [7] "Participation_w3"   "AGET1"              "AGET3"             
# [10] "MIGY"               "GENF"               "EDTERT"            
# [13] "EDNA"               "EMPP"               "EMPNO"             
# [16] "EMPRET"             "EMPNA"              "KIDY"              
# [19] "KIDNA"              "INCT1"              "INCT3"             
# [22] "INCNA"              "TGANC"              "EXT1"              
# [25] "EXT2"               "EXT3"               "MID1"              
# [28] "MID2"               "MID3"               "BO1"               
# [31] "BO2"                "BO3"                "SPEE1"             
# [34] "SPEE2"              "SPEE3"              "FTM1"              
# [37] "FTM2"               "FTM3"               "INR1"              
# [40] "INR2"               "INR3"               "NDSS1"             
# [43] "NDSS2"              "NDSS3"              "NDWO1"             
# [46] "NDWO2"              "NDWO3"              "NDSO1"             
# [49] "NDSO2"              "NDSO3"             


df_w1_CAWI <- 
  dummies_sample |> 
  filter(Interviewmode_w1 %in% "CAWI") |> 
  select(
    pid, hid,
    # Indicators
    EXT1, MID1, FTM1, INR1, NDWO1, NDSS1, NDSO1, SPEE1, BO1,
    
  
    # Predictors
    TGANC, 
    GENF, 
    MIGY, 
    AGET1, AGET3, 
    EDTERT, EDNA,
    EMPP, EMPNO, EMPRET, EMPNA,
    KIDY, KIDNA,
    INCT1, INCT3, INCNA
  )

df_w1_CAWI |> summary()





# Fit LCAs with 1-6 classes; model files are written to ./lca_1-6_classes/
# cluster = "hid": adjust SEs for respondents clustered in households
# starts = c(1000, 500): many random starts to avoid local optima
mplus.lca(
  
  df_w1_CAWI,
  
  type = "categorical",
  ind = c("EXT1", "MID1", "FTM1", "INR1", "NDWO1", "NDSS1", "NDSO1", "BO1", "SPEE1"),
  
  cluster = "hid", 
  classes = 6,
  starts = c(1000, 500), stiterations = 100,
  mplus.run = TRUE)



# misty::result.lca() did not work in our setup, so fit indices are
# extracted below via MplusAutomation::readModels(); a complete fit-index
# summary for all models is available in ../Function_LCAsummary.R.
#result.lca(write = "wave1_cawi_fit.xlsx", plot = TRUE)




#.............................
#.............................
#.......Elbow Plots...........
#.............................
#.............................
infor <- cbind(unlist(readModels("lca_1-6_classes/wave1_cawi_lca-1.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave1_cawi_lca-2.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave1_cawi_lca-3.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave1_cawi_lca-4.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave1_cawi_lca-5.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave1_cawi_lca-6.out")$summaries[c("AIC", "BIC", "aBIC")]))

#...................
### Create dataframe ####

# NOTE: "SABIC" = aBIC (sample-size-adjusted BIC) from the Mplus output
dat <- data.frame(class = factor(rep(1:6, times = 3)),
                  criterium = rep(c("AIC", "BIC", "SABIC"), each = 6),
                  statistic = unlist(c(infor["AIC", ], infor["BIC", ], infor["aBIC", ])))

#...................
### Create elbow plot ####

theme_set(theme_bw())
p <- ggplot(dat, aes(class, statistic)) +
  geom_point() + geom_line(group = 1) +
  facet_grid(. ~ criterium)
p
#...................
### Save figure ####

ggsave("wave1_cawi_elbowplot.png", plot = p, dpi = 300, width = 10, height = 4)


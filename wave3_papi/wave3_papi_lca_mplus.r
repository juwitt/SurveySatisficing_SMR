# #_______________________________________________________________________________


# Wave 3 PAPI
#
# NOTE: variables of this survey phase carry the suffix "_w3"
#
# Fits LCA models with 1-6 classes for the wave-3 PAPI subsample via
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

df_w3_PAPI <- 
  dummies_sample |>
  filter(Interviewmode_w3 %in% "PAPI") |> 
  select(
    pid, hid,
    # Indicators (PAPI: no BO/SPEE - break-off and speeding are CAWI-only
    # paradata; see README variable legend)
    EXT3, MID3, FTM3, INR3, NDWO3, NDSS3, NDSO3,
    
    
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

df_w3_PAPI |> summary()





# Fit LCAs with 1-6 classes; model files are written to ./lca_1-6_classes/
# cluster = "hid": adjust SEs for respondents clustered in households
# starts = c(1000, 500): many random starts to avoid local optima
mplus.lca(
  
  df_w3_PAPI,
  
  type = "categorical",
  ind = c("EXT3", "MID3", "FTM3", "INR3", "NDWO3", "NDSS3", "NDSO3"),
  cluster = "hid", 
  classes = 6,
  starts = c(1000, 500), stiterations = 100,
  mplus.run = TRUE)





#.............................
#.............................
#.......Elbow Plots...........
#.............................
#.............................

infor <- cbind(unlist(readModels("lca_1-6_classes/wave3_papi_lca-1.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave3_papi_lca-2.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave3_papi_lca-3.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave3_papi_lca-4.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave3_papi_lca-5.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-6_classes/wave3_papi_lca-6.out")$summaries[c("AIC", "BIC", "aBIC")]))

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

ggsave("wave3_papi_elbowplot.png", plot = p, dpi = 300, width = 10, height = 4)









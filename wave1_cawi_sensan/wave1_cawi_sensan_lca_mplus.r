# #_______________________________________________________________________________

# sensan sample: CAWI (Wave 1)
#
# Sensitivity analysis: the LCA is applied to the gross wave-1 sample,
# i.e. all wave-1 participants regardless of whether they gave panel
# consent (the main analyses use panel consenters only). The data
# ("sensan" sample in Satisficing1_RR.qmd) is saved as
# ../waves_dummies_sensan.RData and additionally carries the PCONS
# (panel consent) predictor.
#
# Unlike the main analyses, LCA models with 1-10 classes are fitted here.


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

load(file = "../waves_dummies_sensan.RData")
# misty: register the data source for mplus.lca() below
setsource()


# shorter alias of the loaded data
dummies_sensan <- waves_dummies_sensan


dummies_sensan |> 
  select(pid, hid, contains("Interviewmode"), 
         contains("Particip"), AGET1:PCONS) |> 
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
# [28] "BO1"                "SPEE1"              "FTM1"              
# [31] "INR1"               "NDSS1"              "NDWO1"             
# [34] "NDSO1"              "PCONS"             

df_w1_CAWI <-
  dummies_sensan |>
  filter(Interviewmode_w1 %in% "CAWI") |>
  select(
    pid, hid,
    # Indicators (CAWI incl. BO/SPEE paradata; see README variable legend)
    EXT1, MID1, FTM1, INR1, NDWO1, NDSS1, NDSO1, SPEE1, BO1,


    # Predictors
    TGANC,
    GENF,
    MIGY,
    AGET1, AGET3,
    EDTERT, EDNA,
    EMPP, EMPNO, EMPRET, EMPNA,
    KIDY, KIDNA,
    INCT1, INCT3, INCNA,
    PCONS
  )

df_w1_CAWI |> summary()





# Fit LCAs with 1-10 classes; model files are written to ./lca_1-10_classes/
# cluster = "hid": adjust SEs for respondents clustered in households
# starts = c(1000, 500): many random starts to avoid local optima
mplus.lca(

  df_w1_CAWI,

  type = "categorical",
  ind = c("EXT1", "MID1", "FTM1", "INR1", "NDWO1", "NDSS1", "NDSO1", "BO1", "SPEE1"),
  cluster = "hid",
  classes = 10,
  starts = c(1000, 500), stiterations = 100,
  mplus.run = TRUE)


#.............................
#.............................
#.......Elbow Plots...........
#.............................
#.............................

infor <- cbind(unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-1.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-2.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-3.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-4.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-5.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-6.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-7.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-8.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-9.out")$summaries[c("AIC", "BIC", "aBIC")]),
               unlist(readModels("lca_1-10_classes/wave1_cawi_sensan_lca-10.out")$summaries[c("AIC", "BIC", "aBIC")]))
#...................
### Create dataframe ####

# NOTE: "SABIC" = aBIC (sample-size-adjusted BIC) from the Mplus output
dat <- data.frame(class = factor(rep(1:10, times = 3)),
                  criterium = rep(c("AIC", "BIC", "SABIC"), each = 10),
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

ggsave("wave1_cawi_sensan_elbowplot.png", plot = p, dpi = 300, width = 10, height = 4)


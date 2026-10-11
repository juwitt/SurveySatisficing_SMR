

library(pacman)
p_load(tidyverse, openxlsx, writexl)


setwd("~/.../Mplus_Models")



extract_lca_mplus7 <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  
  nclass <- lines |> 
    grep("CLASSES ARE c\\(", x = _, value = TRUE) |> 
    str_extract("(?<=c\\()\\d+") |> 
    as.integer()
  
  conv  <- any(grepl("THE MODEL ESTIMATION TERMINATED NORMALLY", lines))
  llrep <- any(grepl("THE BEST LOGLIKELIHOOD VALUE HAS BEEN REPLICATED", lines))
  
  nparam <- lines |> grep("Number of Free Parameters", x = _, value = TRUE) |>
    str_extract("\\d+") |> as.integer()
  
  nobs <- lines |> grep("Number of observations", x = _, value = TRUE) |>
    str_extract("\\d+") |> as.integer()
  
  loglik <- lines |> grep("^\\s+H0 Value\\s+-", x = _, value = TRUE) |>
    str_extract("-[\\d.]+") |> as.numeric()
  
  scale <- lines |> grep("H0 Scaling Correction Factor", x = _, value = TRUE) |>
    str_extract("[\\d.]+$") |> as.numeric()
  
  aic   <- lines |> grep("Akaike \\(AIC\\)", x = _, value = TRUE) |>
    str_extract("[\\d.]+") |> as.numeric()
  bic   <- lines |> grep("Bayesian \\(BIC\\)", x = _, value = TRUE) |>
    str_extract("[\\d.]+") |> as.numeric()
  sabic <- lines |> grep("Sample-Size Adjusted BIC", x = _, value = TRUE) |>
    str_extract("[\\d.]+") |> as.numeric()
  caic  <- bic + nparam
  
  chi_idx  <- grep("Pearson Chi-Square", lines)[1]
  chi_pear <- if (!is.na(chi_idx)) {
    lines[chi_idx + 2] |> str_extract("[\\d.]+") |> as.numeric()
  } else NA_real_
  
  lrt_idx <- grep("Likelihood Ratio Chi-Square", lines)[1]
  chi_lrt  <- if (!is.na(lrt_idx)) {
    lines[lrt_idx + 2] |> str_extract("[\\d.]+") |> as.numeric()
  } else NA_real_
  
  lmr_idx <- grep("VUONG-LO-MENDELL-RUBIN", lines)
  lmr_p   <- if (length(lmr_idx) > 0) {
    lines[lmr_idx + 7L] |> str_extract("[\\d.]+") |> as.numeric()
  } else NA_real_
  
  alrt_idx <- grep("LO-MENDELL-RUBIN ADJUSTED", lines)
  alrt_p   <- if (length(alrt_idx) > 0) {
    lines[alrt_idx + 3L] |> str_extract("[\\d.]+") |> as.numeric()
  } else NA_real_
  
  entropy_raw <- lines |> grep("^\\s+Entropy", x = _, value = TRUE)
  entropy <- if (length(entropy_raw) > 0) {
    entropy_raw |> str_extract("[\\d.]+") |> as.numeric()
  } else NA_real_
  
  prop_start  <- grep("BASED ON THE ESTIMATED MODEL", lines)
  proportions <- rep(NA_real_, 6)
  if (length(prop_start) > 0) {
    prop_lines <- lines[(prop_start[1] + 5):(prop_start[1] + 5 + nclass - 1)]
    props <- prop_lines |>
      str_trim() |>
      str_extract("[\\d.]+$") |>   
      as.numeric() |>
      na.omit()
    proportions[seq_len(min(length(props), nclass))] <- props[seq_len(min(length(props), nclass))]
  }
  
  
  tibble(
    Folder     = basename(dirname(dirname(filepath))),
    N_raw      = nobs,
    `#Class`   = nclass,
    Conv       = ifelse(conv, "Yes", "No"),
    `#Param`   = nparam,
    logLik     = loglik,
    Scale      = scale,
    `LL Rep`   = ifelse(llrep, "Yes", "No"),
    AIC        = aic,
    CAIC       = caic,
    BIC        = bic,
    SABIC      = sabic,
    `Chi-Pear` = chi_pear,
    `Chi-LRT`  = chi_lrt,
    `LMR-LRT`  = lmr_p,
    `A-LRT`    = alrt_p,
    Entropy    = entropy,
    p1 = proportions[1], p2 = proportions[2], p3 = proportions[3],
    p4 = proportions[4], p5 = proportions[5], p6 = proportions[6],
    p7 = proportions[7], p8 = proportions[8], p9=proportions[9],
    p10 = proportions[10]
  )
}


conditions <- c(
  "wave1_cawi/lca_1-6_Classes",
  "wave1_papi/lca_1-6_Classes",
  "wave2_cawi/lca_1-6_Classes",
  "wave2_papi/lca_1-6_Classes",
  "wave3_cawi/lca_1-6_Classes",
  "wave3_papi/lca_1-6_Classes",
  "wave1_cawi_sensan/lca_1-10_Classes",
  "wave1_papi_sensan/lca_1-10_Classes"
)



lca_summary <- conditions |>
  map(~ {
    files <- list.files(.x, pattern = "\\.out$", full.names = TRUE)
    if (length(files) == 0) return(NULL)
    map_df(files, extract_lca_mplus7)
  }) |>
  compact() |>
  bind_rows() |>
  arrange(Folder, `#Class`) |>
  group_by(Folder) |>
  mutate(
    delta_BIC = BIC - min(BIC, na.rm = TRUE),
    cmPk = round(exp(-0.5 * delta_BIC) / sum(exp(-0.5 * delta_BIC), na.rm = TRUE), 3)
  ) |>
  ungroup()

wb <- createWorkbook()

for (f in sort(unique(lca_summary$Folder))) {
  d     <- lca_summary |> filter(Folder == f)
  n_val <- unique(d$N_raw)[1]
  d     <- d |> select(-Folder, -N_raw)
  
  addWorksheet(wb, f)
  
  title <- paste0("Modell ", f, ", N = ", n_val)
  writeData(wb, f, title, startRow = 1, startCol = 1)
  addStyle(wb, f,
           style = createStyle(textDecoration = "bold", fontSize = 13),
           rows = 1, cols = 1, gridExpand = TRUE
  )
  
  writeData(wb, f, d, startRow = 3, startCol = 1, withFilter = TRUE)
  freezePane(wb, f, firstRow = TRUE, firstCol = TRUE)
}

saveWorkbook(wb, "FitIndices_All_LCA_Models.xlsx", overwrite = TRUE)
print("Done")




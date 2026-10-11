#' Calculation of the mean root of squares of items over multiple item packages
#'
#' @param df The dataframe of interest which includes the columns of interest
#' @param items A list of vectors of colnames() each named in the pattern scalename.items
#' @param missings.threshold the proportion of missings per row and item package. CAVE! missings means values < 0 only. Default: no value is being calculated if > 10% of values are missing in an item package. In that case, NA is displayed
#' @param reg regex describing the item batteries name. Defaults to `"\\d"` meaning that only that part of the strings before any numbers is kept. Alternatives possible, e.g. `".*_"` meaning that only those strings before the "_" is being kept.
#'
#' @description
#' Function calculates the mean of the square roots of absolute differences of all pairs of values for one individual in an item package (rowwise, resulting in `temp_index`). The range of temp_index depends on the given data and the features of the scale, eg number of response alternatives, number of items etc.
#' For `temp_index`, a 0 represents absolute nondiffentiation, meaning that all obsverved values are equal.\cr
#' **Example calculation**: \cr
#' For one individual, observation A, the pcohes-scale items be as follows: pcohes01 = 1, pcohes02 = 4, pcohes03 = 2, pcohes04 = 5.\cr
#' `temp_index_obsA = (sqrt(abs(1-4)) + sqrt(abs(1-2)) + sqrt(abs(1-5)) + sqrt(4-2) + sqrt(abs(4-5)) + sqrt(abs(2-5)))/6 = 1.48`
#' For another individual, observation B, the pcohes-scale items be: pcohes01 = 2, pcohes02 = 3, pcohes03 = 2, pcohes04 = 3.\cr
#' `temp_index_obsB = (sqrt(abs(2-3)) + sqrt(2-2) + sqrt(abs(2-3)) + sqrt(3-2) + sqrt(3-3) + sqrt(abs(2-3)))/6 = 0.67`\cr
#' For the third individual, observation C, the pcohes-scale items be: pcohes01 = 2, pcohes02 = 2, pcohes03 = 2, pcohes04 = 1.\cr
#' `temp_index_obsC = (sqrt(abs(2-2)) + sqrt(2-2) + sqrt(abs(2-1)) + sqrt(2-2) + sqrt(2-2) + sqrt(abs(2-1)))/6 = 0.33`\cr
#' For the fourth individual, observation D, the pcohes-scale items be: pcohes01 = 4, pcohes02 = 4, pcohes03 = 4, pcohes04 = 4.\cr
#' `temp_index_obsD = (sqrt(4-4) + sqrt(4-4) + sqrt(4-4) + sqrt(4-4) + sqrt(4-4) + sqrt(4-4))/6 = 0`
#'
#' The temporary indices are standardized in the next step using the observed minimum and maximum of temp_index within the sample, extending them to a range of 0–1.\cr
#' In this **Example calculation**, the overall temp_index_max = 1.48 (temp_index_obsA) and temp_index_min = 0 (observation D).
#'
#' For the final index (`MeanRootPairs`), 0 represents the maximum of differentiation observed in the data (i.e., the individual with the highest temp_index value in the sample), whereas 1 represents the minimum of differentiation observed in the data (i.e., the individual with the lowest temp_index value in the sample). Note that both poles are empirically anchored: a value of 1 is only attained by the respondent(s) with the lowest observed temp_index, not by a theoretical benchmark. Accordingly, values are not comparable across item batteries or across independent samples, as both temp_index_max and temp_index_min are sample-specific.
#'
#' MeanRootPairs_pcohes_obsA = (1.48 - 1.48)/(0 - 1.48) = 0 \cr
#' MeanRootPairs_pcohes_obsB = (0.67 - 1.48)/(0 - 1.48) = 0.55\cr
#' MeanRootPairs_pcohes_obsC = (0.33 - 1.48)/(0 - 1.48) = 0.78\cr
#' MeanRootPairs_pcohes_obsD = (0 - 1.48)/(0 - 1.48) = 1
#'
#' The resulting (MeanRootPair) value expresses the position of an individual's differentiation behavior relative to the empirically observed range of differentiation within the sample. This standardization ensures that both scale poles are always realized in the data, but also implies that MRP values cannot be compared across different item batteries or across different samples (e.g., survey waves), as the reference distribution shifts with each sample. #' The procedure is based on the description of Mulligan et al., 2001, described by Kim et al., 2019, Chang & Krosnick, 2009, and others.
#' The function is applicable to a list of vectors containing item packages. The item packs should be named in the following form: items_scalename, or otherwise the regex has to be adjusted. The function automatically sets the temp_index of a respondent NA if more than 10% of the items' values are < 0 (thereby indicating a missing). The proportion is adjustable. The function does not have an explicit rule included for dealing with true NAs; it is recommended to recode NAs as negative values (e.g., −9) prior to applying the function.
#' For acceleration of the computation, all columns of interest are being tranformed to numerics before the calculation starts (i.e., columns are being unlabelled).
#'
#'
#'
#' @return A dataframe will be printed to the console. Durations per item package as well as the total duration will be printed to the console.
#' @export
#'
#' @author Anonymized
#' @references
#' Mulligan, K., Krosnick, J. A., Smith, W., Green, M., & Bizer, G. (2001). Nondifferentiation on Attitude Rating Scales: A Test of Survey Satisflcing Theory Manuscript under review.
#' Kim, Y., Dykema, J., Stevenson, J., Black, P., & Moberg, D. P. (2019). Straightlining: Overview of Measurement, Comparison of Indicators, and Effects in Mail–Web Mixed-Mode Surveys. Social Science Computer Review, 37(2), 214–233. https://doi.org/10.1177/0894439317752406.
#' Chang, L., & Krosnick, J. A. (2009). National Surveys Via Rdd Telephone Interviewing Versus the Internet. Public Opinion Quarterly, 73(4), 641–678. https://doi.org/10.1093/poq/nfp075
#' Fricker, S. (2005). An Experimental Comparison of Web and Telephone Surveys. Public Opinion Quarterly, 69(3), 370–392. https://doi.org/10.1093/poq/nfi027
#'
#'
#' @examples
#' require(data.table) #generation of example data
#' require(dplyr)
#' require(lubridate)
#'
#' #example data
#' set.seed(1313)
#' df <- data.table(
#'   first01 = c(4, -2, 4, 5, 6, 2, -1, -1, -9, 4, 5, 1, 3, 4, 3, 4, 5,
#'    -1, -1, 5, 2, 3, 4, 3, 2, 2, -1, -9, 2, 1),
#'   first02 = c(-1, -9, sample(1:5, size = 27, replace = TRUE), -1),
#'   first03 = c(sample(1:5, size = 30, replace = TRUE)),
#'   first04 = c(sample(1:5, size = 30, replace = TRUE)),
#'   first05 = c(sample(1:5, size = 30, replace = TRUE)),
#'   first06 = c(sample(1:5, size = 30, replace = TRUE)),
#'   first07 = c(sample(1:5, size = 30, replace = TRUE)),
#'   first08 = c(sample(1:5, size = 30, replace = TRUE)),
#'   second01 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second02 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second03 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second04 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second05 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second06 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second07 = c(sample(1:11, size = 30, replace = TRUE)),
#'   second08 = c(sample(1:11, size = 30, replace = TRUE)),
#'   third01 = c(sample(1:5, size = 30, replace = TRUE)),
#'   third02 = c(sample(1:5, size = 30, replace = TRUE)),
#'   third03 = c(sample(1:5, size = 30, replace = TRUE)),
#'   third04 = c(sample(1:5, size = 30, replace = TRUE)),
#'   third05 = c(sample(1:5, size = 30, replace = TRUE)),
#'   third06 = c(sample(1:5, size = 30, replace = TRUE)),
#'   fourth = c(sample(1:2, size = 30, replace = TRUE)),
#'   fifth = c(sample(1:11, size = 30, replace = TRUE)))
#'
#'   df[sample(1:30, size = 4), ] <- -10
#'
#'   #select item packages of interest
#'   items_first <- df |> select(contains("first")) |> colnames()
#'   items_second <- df |> select(contains("second")) |> colnames()
#'   items_third <- df |> select(contains("third")) |> colnames()
#'
#'   # aggregate item packages of interest in a list
#'   items_list <- list(items_first, items_second, items_third)
#'
#'
#'
#'   #apply function
#'
#'
#'   df |> meanRootPairs(items_list, 0.1)
#'
#'
#'
#'
#'
#'
#'
#'
meanRootPairs <- function(df, items, reg = "\\d", missings.threshold = 0.10) {


  fun_meanRootPairs <- function(df, items, missings.threshold) {


    if (!requireNamespace("dplyr", quietly = TRUE)) {
      install.packages("dplyr")
    }
    library(dplyr)


    # in case data is labelled, the transformation to numeric saves a lot of time
    vector_list <- items
    all_item_names <- unlist(vector_list)
    df <-
      df |> mutate_at(vars(colnames(df)[colnames(df) %in% all_item_names]), as.numeric)

    # get the name of the itempackage: first element of the vector in the list (only strings, no numbers)
    # exp. "_.*" only keep the strings before "_"
    # "\\d" only keep strings before number
    item_name <- gsub(reg, "", items[[1]][1])

    # introduce and define all names of new variables
    temp_index_name <- paste0("temp_index_", item_name)
    temp_index_min   <- paste0("temp_min_", item_name)
    temp_index_max <- paste0("temp_max_", item_name)
    final_index_name <- paste0("MeanRootPairs_", item_name)


    df |>
      rowwise() |>
      mutate(
        !!temp_index_name := case_when(

          # if proportion of missings in data is higher than threshold - set NA
          (sum(c_across(all_of(items)) < 0) / length(c_across(all_of(items)))) > missings.threshold ~ NA,

          # if not...
          TRUE ~ {

            # take all positive values in the item package of the observation
            positive_items <- c_across(all_of(items))[c_across(all_of(items)) >= 0]

            # if there are at least 2 values (1 pair), we can calculate the minimum of 1 difference
            if (length(positive_items) >= 2) {

              # calculate the square roots of the absolute differences of all combinations of two positive values
              diff_values <- combn(positive_items, 2, function(x) sqrt(abs(diff(x))))

              # Calculate the average of these values
              mean(diff_values, na.rm = TRUE)

            } else {
              # set temp_index for this obs. NA
              NA
            }

          }

        )) |>

      ungroup() |>



      # Create a new column for the maximum of temp_index_name
      mutate(
        !!temp_index_max := max(!!rlang::parse_expr(temp_index_name),  na.rm = TRUE),
        !!temp_index_min := min(!!rlang::parse_expr(temp_index_name),  na.rm = TRUE)   # NEU
      ) |>

      # Go back rowwise
      rowwise() |>

      # Calculate the new value for final_index_name

      mutate(
        # paste the temp_index_name and substract from it the pasted temp_index_max dividing this by
        !!final_index_name := ((!!rlang::parse_expr(temp_index_name) - !!rlang::parse_expr(temp_index_max))/
                                 # minus the pasted temp_index_maximum
                                 (!!rlang::parse_expr(temp_index_min) - !!rlang::parse_expr(temp_index_max)))
      )


  }

  t1 <- Sys.time()


  for (i in seq_along(items)){
    x <- Sys.time()

    # apply the function to all elements of the given list
    df <- fun_meanRootPairs(df, items[[i]], missings.threshold )

    # send an information about the duration of the process to the console
    itempack_name <- gsub(reg, "", items[[i]][1])  # Remove numbers from the name
    cat("Duration for", itempack_name, ":", time_length(interval(x, Sys.time()), "minute"), "minutes\n")

  }

  cat("All done!\nTotal duration for all item packs:", time_length(interval(t1, Sys.time()), "minute"), "minutes.")

  return(df)
}

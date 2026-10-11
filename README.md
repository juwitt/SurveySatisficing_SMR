# SurvSatRR — Replication Materials

This repository contains the complete **Mplus latent class analysis (LCA)
replication materials** for the accompanying registered report on survey
satisficing in a mixed-mode survey (CAWI vs. PAPI), including two
sensitivity analyses on the gross wave-1 sample.

> **No datasets are delivered with this repository.** See
> [Data availability](#data-availability) below.

---

## What is replicated

For each **survey wave (1–3) × interview mode (CAWI/PAPI)**, latent class
analyses classify respondents into satisficing types based on binary
indicators of extreme responding, midpoint responding, free-text
missingness, item nonresponse, three forms of nondifferentiation,
break-off, and speeding. Model selection proceeds from 1- to 6-class
solutions (1–10 for the sensitivity analyses) using AIC/BIC/aBIC elbow
plots and the standard fit criteria, followed by a replicated winner
model and a 3-step (R3STEP) analysis with sociodemographic predictors.

## Repository structure

```
# ---- Part 1: indicator construction and LCA input (Script 1) ----
Satisficing1_RR.qmd            # full preprocessing pipeline (Quarto/R):
                                    # builds the LCA input dummies and saves
                                    # waves_dummies_sample.RData /
                                    # waves_dummies_sensan.RData
                                    # (anonymized master — for peer review)

# ---- Part 2: post-LCA analyses (Script 2) ----
Satisficing2_RR.qmd            # post-LCA analyses: classification
                                    # quality (posterior probabilities,
                                    # entropies, omegas), multinomial and
                                    # logistic models of satisficing types
                                    # across waves, descriptive composition
                                    # of the latent classes
                                    # (anonymized master — for peer review)

wave1_cawi/        # wave 1, CAWI         (main sample)
wave1_papi/        # wave 1, PAPI         (main sample)
wave2_cawi/        # wave 2, CAWI         (main sample)
wave2_papi/        # wave 2, PAPI         (main sample)
wave3_cawi/        # wave 3, CAWI         (main sample)
wave3_papi/        # wave 3, PAPI         (main sample)
wave1_cawi_sensan/ # wave 1, CAWI         (sensitivity analysis, gross sample)
wave1_papi_sensan/ # wave 1, PAPI         (sensitivity analysis, gross sample)

Function_LCAsummary.R              # custom extraction of all LCA fit indices
                                   # (1–6 / 1–10 classes) into an Excel file
satisficingr/                      # companion R package (meanRootPairs etc.)
```

Each wave × mode folder contains:

| File(s) | Content |
|---|---|
| `lca_1-6_classes/wave{N}_{mode}_lca-{1..6}.inp/.out` | LCA models with 1–6 classes (1–10 in the `*_sensan` folders, `lca_1-10_classes/`) |
| `wave{N}_{mode}_rep3.inp/.out` | replicated winner model (3 classes in all eight analyses) |
| `wave{N}_{mode}_rep3_socdem.inp/.out` | winner model with sociodemographic predictors (Mplus AUXILIARY R3STEP) |
| `wave{N}_{mode}_rep3_socdem_annotated.out` | copy of the winner `.out` with class labels added by hand (no model re-estimated — see below) |
| `wave{N}_{mode}_lca_mplus.r` | R script that fits the model series via `misty::mplus.lca()` and creates the AIC/BIC/aBIC elbow plot |
| `wave{N}_{mode}_elbowplot.png` | the resulting elbow plot |

## Script 2 in detail (`Satisficing2_RR.qmd`)

Renders to PDF. It reads the Mplus output of the eight LCAs
(`*_final.dat`, `*_lca-*.out` and the class-probability files) plus the
covariates from the Script 1 pipeline and performs:

1. **Classification diagnostics** — modal class assignment, estimated
   posterior probabilities, class-specific omegas (classification
   quality) and entropies, per wave and mode
2. **Global/omega plots and global grids** — visual classification
   quality and class separation (main sample and sensitivity analyses)
3. **Multinomial and logistic regressions** — satisficing type as a
   function of covariates and of the previous wave's class/mode
   (predicting satisficing across waves)
4. **Class composition** — sociodemographic description of the latent
   classes (income, age, gender, migration background, education)

Inputs besides the raw survey data:

1. The Mplus `*_final.dat` files produced by the LCA runs of step 3.
   They sit in the `lca_1-6_classes` (`lca_1-10_classes` for the
   sensitivity analyses) subfolder of the respective wave × mode folder.
   Save-file names are standardized to the folder, i.e. the
   `wave{N}_{mode}` folder maps to `wave{N}_{mode}_final.dat`, e.g.
   `wave1_cawi/lca_1-6_classes/wave1_cawi_final.dat`,
   `wave3_cawi/lca_1-6_classes/wave3_cawi_final.dat`,
   `wave1_papi_sensan/lca_1-10_classes/wave1_papi_sensan_final.dat`.
   The exact name of each save file is given in the `SAVEDATA` block of
   the corresponding `*_rep3_socdem.inp` / `.out` file
2. A single Excel workbook (`Sample_Summaries.xlsx`, included in this
   repository) with the summaries used for the classification
   diagnostics, the omega/global plots and the multinomial models, read
   via `readxl` from the `userpath` folder

**Note on `Sample_Summaries.xlsx`**: this is a hand-compiled working
sheet — values were copy-pasted from the Mplus model outputs (fit
indices, posterior-probability summaries, omegas, entropies, class
labels) to be able to analyse and name the latent classes and to build
the plots. Individual blocks may be working notes, redundant, or not
used by the final script. The workbook contains no personal data; its
document metadata was anonymized.

## Data availability

The anonymized code and materials used to conduct the analyses reported
in this study, including all data wrangling, cleaning, variable
generation, and latent class analysis (LCA) scripts (R and Mplus
input/output files), are available for peer review in this repository.
Upon acceptance, these materials will be permanently archived at the
corresponding author's GitHub.

**No datasets are included in this repository** — neither the raw survey
data (`.dta`) nor derived files (`waves_dummies_sample.RData`,
`waves_dummies_sensan.RData`, `Data_LCA.dat`, Mplus `SAVEDATA` files).
The only exception is `Sample_Summaries.xlsx` (Script 2), which contains
summaries copied from the Mplus outputs rather than respondent data. The data are available upon request from the
Research Data Centre Social Cohesion of the Research Institute Social
Cohesion
([RDC-RISC](https://fgz-risc-data.de/en/)). A significant proportion of
the variables used in our analysis are also available as a scientific
use file
([doi:10.60532/scp.2021_22.w1.v1](https://doi.org/10.60532/scp.2021_22.w1.v1)).

To re-run, point the four path variables in the setup chunk of each
script (`userpath`, `datapath`, `datapath2`, `cachepath`) to your local
copies of the data, and adapt the `read_*()` calls to your own file
locations.

## How to reproduce

1. **Obtain the data** under a data use agreement and set the paths in
   the setup chunk of `Satisficing1_RR.qmd`.
2. **Render the Quarto document** (`quarto render Satisficing1_RR.qmd`).
   This performs the full preprocessing (indicator construction:
   extreme/midpoint responding, nondifferentiation, speeding, break-off,
   free-text missingness, item nonresponse, SEM-based checks) and saves
   `waves_dummies_sample.RData` / `waves_dummies_sensan.RData` next to the
   wave folders.
3. **Run the eight LCA scripts** `wave*/wave*_*_lca_mplus.r`.
   They load `../waves_dummies_sample.RData` (or `..._sensan.RData`),
   write the Mplus inputs, and — with a local Mplus installation — run
   the 1–6 (1–10) class series and create the elbow plots.
4. **Fit-indices overview**: run `Function_LCAsummary.R` to collect all
   fit indices (convergence, logLik replication, AIC/BIC/aBIC, entropy,
   class proportions, BIC-based evidence ratios) into
   `FitIndices_All_LCA_Models.xlsx`.
5. **Post-LCA analyses**: set the paths in `Satisficing2_RR.qmd`
   and render it (`quarto render Satisficing2_RR.qmd` → PDF). It
   reads the Mplus outputs of step 3 (plus `Sample_Summaries.xlsx`) and
   produces the classification diagnostics, the omega/global plots, the
   multinomial and logistic models, and the class-composition tables.

## Variable legend (names as used in `.inp` / `.out` / `.R`)

All analysis variables are binary dummies coded **1 = reference/no,
2 = yes** (`MISSING IS ALL(-99)` in MPlus). The numeric suffix
**1/2/3 = survey wave 1/ 2/ 3**

IDs / technical (not modelled): `pid` (person id; `IDVARIABLE` in the
socdem models), `hid` (household; `CLUSTER IS hid`),
`Interviewmode_w*` / `Participation_w*` (sample filters in the R scripts
only); model input file is `../Data_LCA.dat`.

Indicators (LCA measurement model; `USEVARIABLES` + `CATEGORICAL`):

| Dummy | Satisficing Strategy |
|---|---|
| EXT | Extreme responding |
| MID | Midpoint responding | 
| FTM | Free-text missingness | 
| INR | Item nonresponse | 
| NDSS | Nondifferentiation strong: sometimes (0–50%) |
| NDWO| Nondifferentiation, weak: often (≥50%) | 
| NDSO | Nondifferentiation, strong: often (≥50%) | 
| BO | Break-off | 
| SPEE | Speeding  | 

PAPI models use the 7 indicators without `BO`/`SPEE` (break-off and
speeding are CAWI-only paradata).

Predictors (only in the 8 `*_rep*_socdem.inp` files, as
`AUXILIARY ... (R3STEP)`), pattern `VAR: description (ref: reference)`:

| Code | Meaning |
|---|---|
| `TGANC`| target group: anchor person (ref: other household member, not anchor person) |
| `AGET1` / `AGET3`| age tertile 1 (18–41) / tertile 3 (61–101) (ref: medium, 2nd tertile) |
| `GENF`| gender: female (ref: not female) |
| `MIGY`| migration background: yes (ref: no migration) |
| `EDTERT` / `EDNA`| tertiary education (ISCED 5–8) / education missing (ref: non-tertiary, ISCED <5) |
| `EMPP` / `EMPNO` / `EMPRET` / `EMPNA`| part-time or flexible / not currently employed or in training / retired / missing (ref: full-time) |
| `KIDY` / `KIDNA`| child in household / missing (ref: no child in hh) |
| `INCT1` / `INCT3` / `INCNA`| equivalent income tertile 1 (min) / tertile 3 (max) / missing (ref: medium) |
| `PCONS`| panel consent: yes (ref: no) — sensitivity analyses only |

The **sensitivity analyses** apply the LCA to the *gross* wave-1 sample,
i.e. all wave-1 participants regardless of whether they gave panel
consent (the main analyses use panel consenters only); the sensan data
additionally carry the `PCONS` predictor.

## Class labels (winner models, 3 classes each)

| Folder | LC1 | LC2 | LC3 |
|---|---|---|---|
| wave1_cawi | Indifferents | Soft Satisficers | Extremists |
| wave1_papi | Indifferents | Extremists | Soft Satisficers |
| wave2_cawi | Soft Satisficers | Extremists | Indifferents |
| wave2_papi | Indifferents | Extremists | Soft Satisficers |
| wave3_cawi | Extremists | Indifferents | Soft Satisficers |
| wave3_papi | Indifferents | Extremists | Soft Satisficers |
| wave1_cawi_sensan | Indifferents | Soft Satisficers | Extremists |
| wave1_papi_sensan | Indifferents | Extremists | Soft Satisficers |

## Post-calculation annotations (manual edits — no model was re-estimated)

All `*_socdem_annotated.out` files are copies of the corresponding
`*_socdem.out` winner-model output for better interpretation. Only header
text was edited; estimates, fit statistics and confidence intervals are
identical (verify with `diff <plain> <annotated>`).

Labels (`Indifferents`, `Soft Satisficers`, `Extremists`) were added in
two blocks only — `RESULTS IN PROBABILITY SCALE`
(`Latent Class N` → `Latent Class N <label>`) and
`LATENT CLASS ODDS RATIO RESULTS`
(`Latent Class X Compared to Latent Class Y` → `... <label> vs. <label>`).
The `CONFIDENCE INTERVALS` block was left unchanged.

### Other post-hoc text edits (also not re-run)

- `TITLE:` lines in all `.inp`/`.out` standardized to
  `Wave {N} {MODE} LCA [Sensitivity Analysis] for {K} LC`
  plus ` - Replication with doubled starts (winner model)` for `rep`,
  ` - Replicated winner model with sociodemographic predictors (R3STEP)`
  for `rep*_socdem`, and ` - Annotated with class labels` for
  `*_annotated.out` (`.out` echoes and standalone headers updated to match).
  New long titles may exceed Mplus' 90-char input limit on re-run.
- `SAVEDATA FILE IS` standardized to `<folder>_final.dat`
  (e.g. `wave1_cawi_final.dat`) in `.inp` and echoed `.out` lines.
- R scripts: comments translated to English, `readModels`/`ggsave` paths
  updated to the renamed files; data logic (`Interviewmode_*`, `df_*`,
  indicators/predictors) untouched. Note: the R scripts automate
  initiating/running the LCAs (via MplusAutomation).

## Software

- **R** (analyses run with 4.5.x) with the packages loaded via `pacman`:
  `tidyverse`, `misty` (≥ 0.8.0 — provides `mplus.lca()`, `setsource()`),
  `MplusAutomation`, `lavaan`, `tidySEM`, `semPlot`, plus the companion
  package **`satisficingr`** (included in this repository; provides
  `meanRootPairs()`, `recode_likert()`, `setna()` — install locally, e.g.
  `remotes::install_local("satisficingr")`).
- **Mplus** (analyses run with VERSION 7; classic ML estimation).
- **Quarto** to render the preprocessing document.

## A note on AI assistance

The annotations and standardizations above (file renames, title/label
edits, translations, variable legend, README) were prepared with AI
assistance (OpenCodeGo) and verified file-by-file (e.g. with `diff`);
no model was re-estimated.

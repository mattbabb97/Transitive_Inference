# README: Capuchin Sequence Learning Task — Computerized Task & Statistical Analysis

## Project Overview

This project examines whether tufted capuchin monkeys (*Sapajus apella*) can learn ordered sequences of stimuli and integrate multiple sequences into a unified mental list. Subjects were trained on three overlapping 3-item sequences and then tested on all possible pairwise combinations of stimuli, including novel pairs never experienced during training.

**Species:** Tufted capuchin monkeys (*Sapajus apella*)  
**N:** 13 subjects (4 males, 9 females)  
**Institution:** Georgia State University, Language Research Center (LRC), Atlanta, GA  
**Task Platform:** Custom Python 3 computerized joystick task

---

## Repository Structure

```
project/
├── README.md
├── task/
│   ├── task.py                 # Main task script (Python 3)
│   └── stimuli/                # Stimulus images (colored/shaped icons)
├── Data/
│   ├── TIL_Master_File.xlsx    # Raw trial-by-trial output files per subject
├── Data Analysis/
│   ├── TIL_Analysis.R          # Primary GLMM models
│   
│   
└── outputs/
    ├── figures/
    └── tables/
```

---

## Computerized Task

### Requirements

- Python 3 ([van Rossum & Drake, 2012](https://docs.python.org/3/))
- A joystick-compatible interface
- Display monitor connected to the testing enclosure

### Task Description

Subjects controlled a small red cursor via a hand-operated joystick to select stimuli presented on a white screen. Each trial began with a grey start button at the center of the screen. After selecting it, stimuli appeared at pseudorandomized, counterbalanced locations (no stimulus appeared in the same location more than 3 times in a row).

### Sequences Trained

| Sequence | Items       |
|----------|-------------|
| Seq 1    | A → B → C  |
| Seq 2    | C → D → E  |
| Seq 3    | E → F → G  |

### Feedback Logic

| Event              | Audio Feedback | Reward          | Penalty     |
|--------------------|---------------|-----------------|-------------|
| Correct item selected (mid-trial) | Short "beep"  | None            | None        |
| Correct sequence completed        | "Ding"        | 1× 45mg pellet  | None        |
| Incorrect item selected           | "Buzz"        | None            | +10s timeout|

Inter-trial interval (ITI): 5 seconds (+ 10s penalty for errors).

### Training Phases

| Phase | Content                             | Notes                          |
|-------|-------------------------------------|--------------------------------|
| 1     | Sequence 1 only                     | Starts with 1 guided block     |
| 2     | Sequence 2 only                     | Starts with 1 guided block     |
| 3     | Sequences 1 + 2 interleaved         |                                |
| 4     | Sequence 3 only                     | Starts with 1 guided block     |
| 5     | All 3 sequences interleaved         |                                |

**Advancement criterion:** ≥80% accuracy across 2 consecutive blocks of 12 trials per sequence.

**Guided trials:** Only the correct stimulus is displayed at one time; stimuli appear sequentially after each correct selection.

**Modified schedule (6 re-trained subjects):** Four of these subjects were re-trained with new stimuli and only advanced to the 3-trial deferred schedule rather than 4-trial. Reinforcement schedule was included as a fixed effect in models if it improved fit.

---

## Testing

### Trial Types

| Category                  | Description                                                  | Reinforced? |
|---------------------------|--------------------------------------------------------------|-------------|
| Adjacent Within-List      | e.g., A→B, D→E (experienced in training)                    | ✅ Yes       |
| Non-Adjacent Within-List  | Endpoints of each sequence (e.g., A→C)                      | ❌ No        |
| Between-List Novel        | Items from different sequences never paired in training      | ❌ No        |

**Between-List Novel Pairs are subdivided into:**

- **Consistent pairs** (e.g., A→G, A→D): Items always maintain the same relative ordinal position across sequences.
- **Conflicting pairs** (e.g., A→E, C→F): Include bridge items (C or E) that occupy different ordinal positions in different sequences — above-chance accuracy here indicates unified list encoding.
- **Equal pairs** (e.g., B→D, D→F): Items occupy the same ordinal position across their respective sequences — accuracy here also indicates unified list encoding.

### Session Structure

Each testing session consisted of:
- **Pre-test phase:** All 3 sequences, 12 trials each (36 total), using the same deferred reinforcement schedule as training. Subjects must reach ≥80% on each sequence to proceed.
- **Testing phase:** 300 trials (225 for modified-schedule subjects), organized into 75 blocks of 4 trials (3 for modified-schedule subjects).

Each block contained:
- 3 adjacent within-list pairs (differentially reinforced)
- 1 novel pair (never reinforced, no auditory feedback on any trial)

**Novel pair exposure:** 25 responses collected per unique novel pair (15 pairs total = 375 novel trials per subject). Only the first 25 exposures were used in analysis to control for learning effects.

**Sessions per subject:** Mean ± SD = 6.92 ± 1.19 sessions.

---

## Statistical Analysis

### Software

- **Language:** R (v3.6.0, R Development Core Team, 2019)
- **IDE:** RStudio
- **Key packages:**
  - `lme4` — GLMMs (`glmer()`)
  - `emmeans` — Post-hoc contrasts and interaction probing
  - `car` — Model comparison with `anova()`

### Model Structure

**Model type:** Binomial Generalized Linear Mixed Effects Model (GLMM)

```r
# Example model call
library(lme4)
model <- glmer(correct ~ [fixed effects] + (1 | subject),
               data = data,
               family = binomial)
```

- **Random effects:** Random intercept for subject (accounts for repeated measures)
- **Fixed effects:** Trial type, reinforcement schedule (if model fit improves), and other theoretically motivated predictors
- **Model selection:** Akaike's Information Criterion (AIC); all final models compared to a null (random effects only) model

### Coefficient Interpretation

Coefficients are on the **log-odds scale** and are reported as **odds ratios**:

- OR > 1: Higher likelihood of a correct response
- OR < 1: Lower likelihood of a correct response
- All models compared to null model using `anova()` from `car`

### Significance Testing

- **Fixed effects:** Wald's Type III Chi-Square tests
- **Interactions:** Probed using `emmeans()` or `emtrends()` with Holm's adjustment for multiple comparisons
- **Chance comparisons:** One-sample t-tests on subject-level mean accuracy vs. 0.50, Holm-corrected

```r
library(emmeans)
emmeans(model, pairwise ~ trial_type, adjust = "holm")
```

### Model Diagnostics

All models were checked for:

- ✅ Successful convergence and reasonable parameter estimates
- ✅ Residual patterns (no systematic violations)
- ✅ Dispersion (no overdispersion)
- ✅ Influential observations
- ✅ Collinearity (VIF < 1.1 for all predictors)

See `analysis/model_diagnostics.R` and Supplementary Information for full diagnostic output.

---

## Data Notes

- Stimulus positions were pseudorandomized and counterbalanced: no stimulus appeared in the same location >3 times consecutively, and the same novel pair never appeared in consecutive blocks.
- Each unique novel pair appeared a maximum of 5 times per session.
- For subjects completing multiple sessions, only the first 25 exposures to each novel pair were included.
- Pre-test failures (subject did not reach ≥80% or did not finish a block in a session): occurred **14 times across 5 subjects** — those sessions were excluded from testing.

## Contact

For questions about the task code or analysis, contact the corresponding author at matthew.h.babb@gmail.com.

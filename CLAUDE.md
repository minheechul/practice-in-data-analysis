# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is the course website for **Practice in Data Analysis [D01601101]**, a Korean-language undergraduate course teaching R and applied data analysis. It is a [Quarto](https://quarto.org) website project (`project: type: website`) that publishes the syllabus, schedule, and weekly lecture/lab materials (`weekNN.qmd`). All prose content is written in Korean.

## Commands

Rendering requires Quarto (and R with the packages referenced in course scripts, e.g. `tidyverse`, `janitor`, `skimr`, `gapminder`, `here`) to be installed locally.

- Render the whole site: `quarto render`
- Preview with live reload: `quarto preview`
- Render a single page: `quarto render week01.qmd`

There is no test suite, linter, or build step beyond Quarto rendering — this is a content site, not an application.

## Architecture / structure

- `_quarto.yml` — site-wide config: navbar, sidebar (`contents:` lists which `.qmd` files appear, in order, under "강의자료"), and HTML format options (theme `cosmo`, `styles.css`). **When adding a new week's page, register it in `_quarto.yml`'s sidebar `contents:` list**, not just create the file — otherwise it won't appear in navigation. Other settings: `execute: freeze: auto` (R code is re-run only when the source changes; cached in `_freeze/`), render targets are `*.qmd` and `*.md` except `CLAUDE.md` and `for_later_use/`, and `resources:` copies `data/*.csv` and `scripts/*.R` into the site (note: the actual folder is `script/`, not `scripts/`).
- `index.qmd`, `syllabus.qmd`, `schedules.qmd` — top-level pages linked from the navbar.
- `weekNN.qmd` — one file per week of lecture content (currently `week01.qmd` through `week07.qmd`; week08 onward not yet written). Each follows the same pattern: a lecture/setup section followed by a `## 실습` (practice/exercise) section with numbered questions. New weeks should follow this existing structure and numbering convention (`weekNN`).
  - Current content: week01 R/RStudio intro, week02 dplyr, week03 ggplot2, week04 worker-level data (KLIPS), week05 time series, week06 trade data (BACI/CEPII, gravity model, plotly), week07 linear regression (`lm`, `broom`, prediction; gapminder + KLIPS).
  - `schedules.qmd` is the source of truth for the overall 16-week course structure (topic per week) — consult it to understand what a given week should cover before writing or editing a `weekNN.qmd`. Note that the `weekNN.qmd` numbering is intentionally one behind `schedules.qmd` from week 4 on (the schedule's week 4 is a holiday with no class); keep both as they are.
- `files/` — downloadable assets referenced from lecture pages:
  - `report_template.docx` — Word template students use to submit written answers.
  - `week01_1.R` — the R script template used in `week01.qmd`'s example walkthrough (env setup → load data → explore → transform → visualize → model → save output), following a fixed 7-step pedagogical structure (환경준비 → 데이터 불러오기 → 특성 파악 → 데이터 변형 → 시각화 → 모형 추정 → 결과 저장). New week scripts should follow this same 7-step structure for consistency.
- `data/` — datasets read by the lecture pages (KLIPS, Bank of Korea time series, trade/country code CSVs, etc.), small enough to commit to GitHub.
- `large_data/` — datasets too large for GitHub (e.g. `baci_kor_import.csv`, `gravity_small.csv`). **Gitignored**, so they exist only locally; pages that depend on them cannot be rendered from a fresh clone.
- `script/` — R scripts per week (`weekNN.R`) and data-preparation scripts (`*_prep_*.R`) that build the files in `data/` and `large_data/`.
- `ps/` — problem sets (Rmd/pdf).
- `_freeze/` — Quarto freeze cache (`freeze: auto`) for executed pages; committed to git.
- `images/` — screenshots embedded in `.qmd` files (e.g. RStudio setup screenshots).
- `simulator_template.html` — standalone HTML/Bootstrap/Plotly template for building interactive simulators (sliders driving a Plotly graph); not wired into the Quarto site nav, used as a starting point when a lecture needs an interactive demo.
- `_site/` — Quarto's rendered HTML output. It is **gitignored** (along with `.quarto/`, `*.quarto_ipynb`, `large_data/`, `for_later_use/`), so it is not committed; do not include it in commits.
- `styles.css` — custom site-wide CSS (Korean-friendly font stack, spacing tweaks for headings/lists/sidebar).

## Content conventions

- Page content and navigation labels are in Korean; keep new content consistent with the existing tone/register.
- Every week's page must include a `## 실습` (practice/exercise) section following the same format as `week01.qmd` (numbered questions tied to the script walkthrough, submission instructions).
- Weeks 1–3 use the `gapminder` dataset, to let students get used to the tools before switching data. Prefer datasets available through an R package (e.g. `WDI`) over external files. When an external file is needed (as in weeks 4–6), put it in `data/`; if it is too large for GitHub, put it in `large_data/` (gitignored).
- Student-facing file naming convention used throughout instructions: `weekNN_script_학번.R` and `weekNN_answer_학번.docx` (학번 = student ID number) for assignment submissions.
- R code examples consistently use the tidyverse pipe (`|>`), `library(tidyverse)`, `library(janitor)`, `library(skimr)`, and `ggplot2`/`ggsave()` for figures.

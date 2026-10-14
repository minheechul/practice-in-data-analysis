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

- `_quarto.yml` — site-wide config: navbar, sidebar (`contents:` lists which `.qmd` files appear, in order, under "강의자료"), and HTML format options (theme `cosmo`, `styles.css`). **When adding a new week's page, register it in `_quarto.yml`'s sidebar `contents:` list**, not just create the file — otherwise it won't appear in navigation.
- `index.qmd`, `syllabus.qmd`, `schedules.qmd` — top-level pages linked from the navbar.
- `weekNN.qmd` — one file per week of lecture content (currently `week01.qmd`, `week02.qmd`). Each follows the same pattern: a lecture/setup section followed by a `## 실습` (practice/exercise) section with numbered questions. New weeks should follow this existing structure and numbering convention (`weekNN`).
  - `schedules.qmd` is the source of truth for the overall 16-week course structure (topic per week) — consult it to understand what a given week should cover before writing or editing a `weekNN.qmd`.
  - **`week02.qmd` is currently a stale placeholder** (its content is a leftover copy of `week01.qmd`'s 실습 section, not actual week 2 material) — ignore it as a reference for content/structure until it has been rewritten.
- `files/` — downloadable assets referenced from lecture pages:
  - `report_template.docx` — Word template students use to submit written answers.
  - `week01_1.R` — the R script template used in `week01.qmd`'s example walkthrough (env setup → load data → explore → transform → visualize → model → save output), following a fixed 7-step pedagogical structure (환경준비 → 데이터 불러오기 → 특성 파악 → 데이터 변형 → 시각화 → 모형 추정 → 결과 저장). New week scripts should follow this same 7-step structure for consistency.
- `images/` — screenshots embedded in `.qmd` files (e.g. RStudio setup screenshots).
- `simulator_template.html` — standalone HTML/Bootstrap/Plotly template for building interactive simulators (sliders driving a Plotly graph); not wired into the Quarto site nav, used as a starting point when a lecture needs an interactive demo.
- `_site/` — Quarto's rendered HTML output. Unlike a typical Quarto project, **`_site/` is committed to git** (only `.quarto/` and `*.quarto_ipynb` are gitignored), so it must be re-rendered and included in commits when source `.qmd` files change, since it likely serves as the published/deployed version of the site.
- `styles.css` — custom site-wide CSS (Korean-friendly font stack, spacing tweaks for headings/lists/sidebar).

## Content conventions

- Page content and navigation labels are in Korean; keep new content consistent with the existing tone/register.
- Every week's page must include a `## 실습` (practice/exercise) section following the same format as `week01.qmd` (numbered questions tied to the script walkthrough, submission instructions).
- Weeks 1–3 should keep using the `gapminder` dataset by default, to let students get used to the tools before switching data. If a week's 실습 needs a different dataset, prefer one available through an R package (e.g. `WDI`) over an external file.
- Student-facing file naming convention used throughout instructions: `weekNN_script_학번.R` and `weekNN_answer_학번.docx` (학번 = student ID number) for assignment submissions.
- R code examples consistently use the tidyverse pipe (`|>`), `library(tidyverse)`, `library(janitor)`, `library(skimr)`, and `ggplot2`/`ggsave()` for figures.

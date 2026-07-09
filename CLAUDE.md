# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal website / blog at https://ulmefors.com, built on [fastpages](https://github.com/fastai/fastpages) (a Jekyll template that also supports Jupyter notebooks and Word docs as blog post sources). Deployed to GitHub Pages via the `CI` workflow in `.github/workflows/ci.yaml` on pushes to `master`.

## Common commands

Everything runs in Docker via `docker-compose`. See `Makefile` for the full list.

- `make server` — start the Jekyll dev server (http://localhost:4000). Runs `docker-compose down` first so it's safe to re-run.
- `make server-detached` — same, detached.
- `make build` — full rebuild of the Docker images with no cache. Use after changing `Gemfile` / Dockerfiles.
- `make quick-build` — rebuild images with cache.
- `make convert` — run only the notebook/word → post converter (no Jekyll server).
- `make stop` / `make remove` — stop / remove containers.
- `make bash-jekyll` / `make bash-nb` — shell into the running Jekyll or notebook-watcher container.
- `make restart-jekyll` — restart just the Jekyll service (containers must be up).

There is no test suite. CI just runs `jekyll build --strict_front_matter --trace` inside the `fastai/fastpages-jekyll` image and deploys `_site/` to GitHub Pages.

## Architecture

Content flows through two stages: **conversion** (notebooks/word → markdown) and **Jekyll build** (markdown → static site).

- `_posts/` — the primary content source. Filenames must be `YYYY-MM-DD-*.md`. Front matter drives layout, categories, and image previews.
- `_notebooks/` and `_word/` — source Jupyter notebooks and `.docx` files. The `converter` / `watcher` docker service (see `docker-compose.yml`, wired to `_action_files/action_entrypoint.sh`) transforms these into posts. This same conversion runs in CI before `jekyll build`.
- `_pages/` — standalone pages (about, 404, tags, search). Included via the `include: [_pages]` setting in `_config.yml`.
- `_layouts/`, `_includes/`, `_sass/` — standard Jekyll theming on top of the `minima` theme (pinned to a specific commit in `Gemfile`).
- `_plugins/` — local Ruby plugins (footnotes). Note: local plugins don't work on GitHub Pages' default build, which is why this site uses a custom GitHub Actions build (`ci.yaml`) rather than the built-in Pages builder.
- `_action_files/` — the fastpages "action" — Dockerfile plus Python/shell scripts (`nb2post.py`, `word2post.py`, etc.) that do the notebook/word conversion. Also referenced as a local action from `ci.yaml` (`uses: ./_action_files`).
- `_site/` — Jekyll build output. Not committed except when locally built; ignore in edits.
- `settings.ini` and `_config.yml` — fastpages/Jekyll settings. `_config.yml` is the one that matters for site behavior (title, plugins, analytics, pagination).

## Gemfile pinning

Several gems are pinned to older majors to keep Ruby-version compat with the `fastai/fastpages-jekyll` Docker image and GitHub Actions. Don't casually bump `activesupport`, `nokogiri`, `public_suffix`, `ffi`, `securerandom`, or `faraday` past the pinned upper bounds — the inline comments explain each ceiling (mostly "next major requires ruby >= 3.0/3.1").

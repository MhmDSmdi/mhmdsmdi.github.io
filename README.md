# mhmdsmdi.github.io

Personal homepage of **Mohammadreza Samadi** - live at <https://mhmdsmdi.github.io>.

Built with [Jekyll](https://jekyllrb.com/) on a trimmed-down fork of the
[al-folio](https://github.com/alshedivat/al-folio) theme, and published by
GitHub Actions using GitHub Pages' native deployment.

## Running it locally

Requires **Ruby 3.1+** and ImageMagick. Note that macOS ships Ruby 2.6, which is
too old - install a newer one with `brew install ruby`, `rbenv`, or `mise`.

On macOS, this checks everything and installs the gems for you:

```bash
bash bootstrap-macos.sh
```

Otherwise, by hand:

```bash
bundle install
bundle exec jekyll serve --livereload
```

Then open <http://localhost:4000>.

`bundle exec jekyll build` produces the static site in `_site/`.

## Where things live

| Path | What it is |
|---|---|
| `_pages/about.md` | The homepage text, profile photo and subtitle |
| `_bibliography/papers.bib` | Publications. `selected={true}` promotes an entry to the homepage |
| `assets/img/publication_preview/` | Thumbnails referenced by `preview={...}` in the `.bib` |
| `assets/pdf/cv.pdf` | The CV the nav bar links to |
| `_news/` | Optional news items (currently empty; set `news: true` in `_pages/about.md` to show them) |
| `funeditor/` | Standalone project page, served verbatim at `/funeditor/` |
| `_config.yml` | Site-wide settings |
| `_sass/`, `assets/css/main.scss` | Styles |

## Adding a publication

Append a BibTeX entry to `_bibliography/papers.bib`. Useful non-standard keys:

- `selected={true}` - also show it on the homepage
- `preview={filename.png}` - thumbnail from `assets/img/publication_preview/`
- `abbr`, `arxiv`, `pdf`, `code`, `website` - render as links/badges

If you add a publication from a year not already listed, add that year to the
`years:` list in `_pages/publications.md`.

## Deploying

Push to `master`. The workflow in `.github/workflows/deploy.yml` builds the
site and hands it to GitHub Pages. Pull requests run the same build as a check
without publishing.

> **One-time setup:** *Settings -> Pages -> Build and deployment -> Source* must be
> set to **GitHub Actions**.

## Licence

Theme is MIT (see `LICENSE`, © al-folio contributors). Site content and the
`funeditor/` project page are © Mohammadreza Samadi.

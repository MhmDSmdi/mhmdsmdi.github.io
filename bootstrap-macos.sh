#!/usr/bin/env bash
# Gets this site building on macOS.
#
#   bash bootstrap-macos.sh
#
# Checks for a modern Ruby and ImageMagick, then installs the gems into
# vendor/bundle (project-local, no sudo, nothing touched system-wide).
# It tells you what to run rather than silently installing things.

set -uo pipefail

RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; DIM=$'\033[2m'; OFF=$'\033[0m'
ok()   { echo "${GRN}  ok${OFF}  $*"; }
bad()  { echo "${RED} !!${OFF}  $*"; }
warn() { echo "${YLW}  ~ ${OFF}  $*"; }
hint() { echo "${DIM}      $*${OFF}"; }

fail=0
echo
echo "Checking prerequisites"
echo "----------------------"

# ---------------------------------------------------------------- Ruby -----
need_ruby=0
if command -v ruby >/dev/null 2>&1; then
  rv=$(ruby -e 'print RUBY_VERSION' 2>/dev/null)
  rmaj=${rv%%.*}; rmin=$(echo "$rv" | cut -d. -f2)
  if [ "$rmaj" -gt 3 ] || { [ "$rmaj" -eq 3 ] && [ "$rmin" -ge 1 ]; }; then
    ok "ruby $rv  ($(command -v ruby))"
  else
    bad "ruby $rv is too old - Jekyll needs >= 3.1"
    hint "$(command -v ruby)"
    need_ruby=1; fail=1
  fi
else
  bad "no ruby on PATH"; need_ruby=1; fail=1
fi

if [ "$need_ruby" = 1 ]; then
  echo
  echo "  Install a modern Ruby. Pick ONE:"
  echo
  if command -v mise >/dev/null 2>&1; then
    echo "  mise (you already have it):"
    echo "      mise use -g ruby@3.3"
  elif command -v rbenv >/dev/null 2>&1; then
    echo "  rbenv (you already have it):"
    echo "      rbenv install 3.3.6 && rbenv local 3.3.6"
  elif command -v asdf >/dev/null 2>&1; then
    echo "  asdf (you already have it):"
    echo "      asdf install ruby 3.3.6 && asdf local ruby 3.3.6"
  fi
  if command -v brew >/dev/null 2>&1; then
    prefix=$(brew --prefix 2>/dev/null)
    echo
    echo "  Homebrew (simplest):"
    echo "      brew install ruby"
    echo "      echo 'export PATH=\"$prefix/opt/ruby/bin:\$PATH\"' >> ~/.zshrc"
    echo "      exec zsh"
  else
    echo "  Homebrew is not installed. Get it from https://brew.sh, then:"
    echo "      brew install ruby"
  fi
  echo
  echo "  Then re-run this script."
  echo "  ${DIM}Do NOT 'sudo gem install' into the system Ruby - that is the 2.6 one.${OFF}"
fi

# --------------------------------------------------------- ImageMagick -----
# jekyll-imagemagick shells out to generate the responsive WebP variants
# under assets/img/.
if command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1; then
  ok "imagemagick ($(command -v magick || command -v convert))"
else
  bad "imagemagick not found - jekyll-imagemagick needs it"
  hint "brew install imagemagick"
  fail=1
fi

# --------------------------------------------------------------- Node ------
# Optional: if node is present, ExecJS uses it and mini_racer never has to
# compile V8, which is the most fragile part of the install.
if command -v node >/dev/null 2>&1; then
  ok "node $(node -v)  ${DIM}(ExecJS will use this; mini_racer stays out of the way)${OFF}"
else
  warn "no node - fine, but mini_racer will have to build V8 to minify assets"
  hint "brew install node   # optional, makes the install more robust"
fi

if [ "$fail" != 0 ]; then
  echo
  echo "${RED}Fix the items marked !! above, then re-run.${OFF}"
  exit 1
fi

# ------------------------------------------------------------ Bundler ------
echo
echo "Installing gems"
echo "---------------"
if ! command -v bundle >/dev/null 2>&1; then
  echo "  installing bundler..."
  gem install bundler --no-document || { bad "gem install bundler failed"; exit 1; }
fi

# Project-local install: no sudo, and nothing leaks into your system gems.
bundle config set --local path vendor/bundle >/dev/null

if bundle install; then
  echo
  ok "gems installed"
  echo
  echo "Commit the lockfile that was just generated:"
  echo "      git add Gemfile.lock && git commit -m 'Add Gemfile.lock'"
  echo
  echo "Then start the preview:"
  echo "      bundle exec jekyll serve --livereload"
  echo "      open http://localhost:4000"
else
  echo
  bad "bundle install failed"
  echo
  echo "  Most likely culprit is ${YLW}mini_racer${OFF} (it compiles V8)."
  echo "  It is only needed to minify the built HTML/CSS/JS - worth maybe 15 KB"
  echo "  on a site this size. To drop it and move on:"
  echo
  echo "      # remove these two lines from the Gemfile:"
  echo "      #     gem 'jekyll-minifier'"
  echo "      #     gem 'mini_racer'"
  echo "      # and remove '- jekyll-minifier' from the plugins: list in _config.yml"
  echo "      bundle install"
  echo
  echo "  If it was ${YLW}eventmachine${OFF} instead, that is the --livereload"
  echo "  dependency. Either install openssl and retry:"
  echo "      brew install openssl@3"
  echo "      bundle config build.eventmachine --with-openssl-dir=\$(brew --prefix openssl@3)"
  echo "      bundle install"
  echo "  ...or just skip livereload and run 'bundle exec jekyll serve'."
  exit 1
fi

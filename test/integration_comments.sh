#!/usr/bin/env bash
set -euo pipefail

# Validates the starter's demo comment posts. A personalized site may have
# removed them; skip the corresponding checks when the source post is absent
# instead of failing the build.

find_demo_post() {
  find _posts -maxdepth 1 -name "$1" -print -quit 2>/dev/null || true
}

post_year() {
  basename "$1" | cut -d- -f1
}

giscus_post="$(find_demo_post '*-giscus-comments.md')"
disqus_post="$(find_demo_post '*-disqus-comments.md')"

if [ -z "${giscus_post}" ] && [ -z "${disqus_post}" ]; then
  echo "comments integration checks skipped: no demo comment posts in _posts/"
  exit 0
fi

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

if [ -n "${giscus_post}" ]; then
  giscus_page="${tmp_site}/blog/$(post_year "${giscus_post}")/giscus-comments/index.html"
  grep -q 'https://giscus.app/client.js' "${giscus_page}"
  if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
    echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
    exit 1
  fi
fi

if [ -n "${disqus_post}" ]; then
  disqus_page="${tmp_site}/blog/$(post_year "${disqus_post}")/disqus-comments/index.html"
  grep -q 'id="disqus_thread"' "${disqus_page}"
  grep -q '.disqus.com/embed.js' "${disqus_page}"
fi

echo "comments integration checks passed"

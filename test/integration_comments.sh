#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"
posts_dir="_posts"
created_posts_dir=0
giscus_post="${posts_dir}/2022-12-10-ci-giscus-comments-fixture.md"
disqus_post="${posts_dir}/2015-10-20-ci-disqus-comments-fixture.md"

cleanup() {
  rm -f "${giscus_post}" "${disqus_post}"
  if [ "${created_posts_dir}" -eq 1 ]; then
    rmdir "${posts_dir}" 2>/dev/null || true
  fi
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

if [ ! -d "${posts_dir}" ]; then
  mkdir -p "${posts_dir}"
  created_posts_dir=1
fi

cat >"${giscus_post}" <<'MARKDOWN'
---
layout: post
title: "CI giscus comments fixture"
date: 2022-12-10
giscus_comments: true
---

Fixture post used by integration tests.
MARKDOWN

cat >"${disqus_post}" <<'MARKDOWN'
---
layout: post
title: "CI disqus comments fixture"
date: 2015-10-20
disqus_comments: true
---

Fixture post used by integration tests.
MARKDOWN

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
disqus_shortname: al-folio-test
YAML

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/blog/2022/ci-giscus-comments-fixture/index.html"
disqus_page="${tmp_site}/blog/2015/ci-disqus-comments-fixture/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"

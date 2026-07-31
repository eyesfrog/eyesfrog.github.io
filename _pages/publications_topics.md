---
layout: page
permalink: /publications/topics/
title: by topics
description: Publications grouped by research topic, in reverse chronological order of release within each topic.
nav: false
---

<!-- _pages/publications_topics.md -->

An up-to-date list is available on [Google Scholar](https://scholar.google.com/citations?hl=en&user=cF8RgGwAAAAJ). An asterisk (<sup>\*</sup>) after my name indicates papers whose authors are ordered alphabetically or contributed equally as co-first authors.

<div class="publications">

<h2 class="bibliography">Quantum Machine Learning</h2>

{% bibliography --query @*[topic=qml] --group_by none %}

<h2 class="bibliography">Quantum Algorithms and Complexity</h2>

{% bibliography --query @*[topic=quantum-algorithms] --group_by none %}

<h2 class="bibliography">Learning and Characterizing Quantum Systems</h2>

{% bibliography --query @*[topic=quantum-learning] --group_by none %}

</div>

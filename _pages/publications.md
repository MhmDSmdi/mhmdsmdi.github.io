---
layout: page
permalink: /publications/
title: Publications
description: Ordered in reverse chronological order.
years: [2026, 2025, 2023, 2021]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

{%- comment -%}
  Each entry carries its own year in the left gutter, so the per-year headings
  that used to sit here would just repeat it. Looping over `years` in
  descending order is what puts the list in reverse chronological order.
{%- endcomment -%}
{%- for y in page.years %}
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

</div>

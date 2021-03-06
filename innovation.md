---
layout: page
title: Innovation
title_summary: because technology should benefit the common good
permalink: /innovation/
weight: 4
---



{% multicols pageintro half %}

<img src="/images/other/innovation-graphic.png" alt="innovation points" role="banner">

<--colbreak-->

<h2 class="grey intro-title">Tackling the world’s toughest problems by challenging established boundaries and partnering to research and co-create impactful solutions.</h2>
{% endmulticols %}

<div class="page-section">
<h3 class="blue">Development Gateway builds on over 15 years of technical and institutional expertise. Through developing tools, processes, and custom analyses, we help our partners better collect and understand information to achieve greater impact.</h3>

<p>The Development Gateway team is a unique mix of techies — software engineers who research and build innovative new tools — and non-techies who understand development challenges. Most of our team members speak more than one language and have worked in various parts of the world. Project teams include members with a mix of skills, so that we approach problems with institutional as well as technical aspects in mind.</p>
</div>

<div class="page-layout-element">
  <h3>Innovation stories released by Development Gateway</h3>
  <div class="columns-3 clearfix">
    {% for post in site.posts | limit: 8 %}
    <div class="blog-entry-wrapper column clearfix">
      <article class="blog-entry">
        <div class="blog-image-wrapper">
          {% image thumb_large {{ post.thumbnail | prepend: site.baseurl }} alt="{{ post.thumbnail-alt }}" %}
        </div>

        <div class="blog-info">
          <h3 class="blog-title"><a href="{{ post.url }}">{{ post.title }}</a></h3>

          <div class="blog-lede">{{ post.lede | markdownify }}</div>

          <p class="blog-date">{{ post.date | date: '%B %d, %Y' }}</p>
        </div>
      </article>
    </div>
    {% endfor %}
  </div>
</div>

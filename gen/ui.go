package main

import "html/template"

var articlePage = template.Must(template.New("article").Parse(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{.Title}}</title>
  <link rel="alternate" href="feed.atom" type="application/atom+xml" />
  {{- if .Canonical }}
  <link rel="canonical" href="{{.Canonical}}">
  {{- end }}
	<style>
		body {
			color: #3c3c3c;
			font-family: -apple-system, BlinkMacSystemFont, "Avenir Next", "Avenir", "Segoe UI", "Lucida Grande", "Helvetica Neue", "Helvetica", "Fira Sans", "Roboto", "Noto", "Droid Sans", "Cantarell", "Oxygen", "Ubuntu", "Franklin Gothic Medium", "Century Gothic", "Liberation Sans", sans-serif;
			font-size: 16px;
			line-height: 22px;
			-webkit-font-smoothing: antialiased;
		}

		a,
		a:visited,
		a:hover {
			border-bottom-color: #da393f;
			border-bottom-style: solid;
			border-bottom-width: 1px;
			color: #3c3c3c;
			text-decoration: none;
			text-decoration-skip: ink;
		}

		a:hover {
			color: #da393f;
		}

		.container {
			margin: 1.5rem 1rem;
			max-width: 700px;
		}

		@media all and (max-width: 575px) {
			.container {
				margin: 1rem 0;
			}
		}

		img {
			max-width: 100%;
		}

		article {
			margin: 1.5rem 0;
		}

		h2 {
			line-height: 26px;
			margin: 2rem 0 1.5rem;
		}

		p,
		ul {
			margin: 1rem 0;
		}

		li {
			margin: 0.5rem 0;
		}

		.lede {
			margin: 20px 0;
		}

		.lede__headline {
			font-size: 32px;
			line-height: 38px;
			margin: 0;
		}

		.lede__byline {
			line-height: 22px;
			margin: 5px 0;
		}

		.lede__author {
			margin-bottom: 0.25rem;
		}

		.lede__author a,
		.lede__author a:visited {
			font-weight: bold;
			text-decoration: none;
		}

		pre {
			background-color: #f7f7f7;
			border-radius: 3px;
			line-height: 1.5;
			overflow-x: scroll;
			padding: 10px;
			word-wrap: normal;
		}

		code {
			background-color: #f7f7f7;
			font-family: "SFMono-Regular",Consolas,"Liberation Mono",Menlo,monospace;
			font-size: 88%;
			word-wrap: break-word;
		}

		:not(pre)>code {
			margin: 0 0.05em;
			padding: 3px 5px;
		}

		footer {
			margin: 20px 0;
		}
	</style>
  <link rel="icon" href="data:;base64,iVBORw0KGgo=">
</head>
<body>
  <div class="container">
    <nav>
      <a href="/">
        {{.Site.Name}} &larr;
      </a>
    </nav>

    <article>
      <header class="lede">
        <h1 class="lede__headline">{{.Title}}</h1>

        <div class="lede__byline">
          {{- range .Authors }}
            <div class="lede__author">
              <a href="{{.URL}}" rel="author">{{.Name}}</a>
            </div>
          {{- end }}

          <time datetime="{{.LastUpdated}}">
            last updated {{.LastUpdatedOn}}
          </time>
        </div>
      </header>
      {{.Body}}
    </article>

    <footer>
      {{- if .Site.SourceURL }}
        <a href="{{.Site.SourceURL}}/articles/{{.ID}}.md">Edit this article</a>
      {{- end }}
    </footer>
  </div>
</body>
</html>`))

var indexPage = template.Must(template.New("index").Parse(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{.Name}}</title>
  <link rel="alternate" href="feed.atom" type="application/atom+xml" />
	<style>
		body {
			color: #3c3c3c;
			font-family: -apple-system, BlinkMacSystemFont, "Avenir Next", "Avenir", "Segoe UI", "Lucida Grande", "Helvetica Neue", "Helvetica", "Fira Sans", "Roboto", "Noto", "Droid Sans", "Cantarell", "Oxygen", "Ubuntu", "Franklin Gothic Medium", "Century Gothic", "Liberation Sans", sans-serif;
			font-size: 16px;
			line-height: 22px;
			-webkit-font-smoothing: antialiased;
		}

		a,
		a:visited,
		a:hover,
		.index-article__link:hover {
			border-bottom-color: #da393f;
			border-bottom-style: solid;
			border-bottom-width: 1px;
			color: #3c3c3c;
			text-decoration: none;
			text-decoration-skip: ink;
		}

		a:hover {
			color: #da393f;
		}

		.container {
			margin: 1.5rem 1rem;
			max-width: 700px;
		}

		@media all and (max-width: 575px) {
			.container {
				margin: 1rem 0;
			}
		}

		main {
			margin: 1.5rem 0;
		}

		nav .tags {
			margin: 1.5rem 0 0.5rem 0;
		}

		.index-article {
			margin: 1rem 0;
		}

		.index-article__link {
			border-bottom: none;
			font-size: 18px;
			font-weight: bold;
			line-height: 22px;
			margin: 0;
		}

		.index-article__link:hover {
			color: #3c3c3c;
		}
	</style>
  <link rel="icon" href="data:;base64,iVBORw0KGgo=">
</head>
<body>
  <div class="container">
    <nav>
      {{.Name}}

      {{- if .Tags }}
        <div class="tags">
          {{- range $tag, $count := .Tags }}
            <a href="/tags/{{$tag}}">{{$tag}}</a>&nbsp;
          {{- end }}
        </div>
      {{- end }}
    </nav>

    <main>
      {{- range .Articles }}
        <div class="index-article">
          <a href="/{{.ID}}" class="index-article__link">
            {{.Title}}
          </a>

          <div class="index-article__byline">
            <time datetime="{{.LastUpdated}}" class="index-article__published-on">
              {{.LastUpdatedIn}}
            </time>
          </div>
        </div>
      {{- end }}
    <main>
  </div>
</body>
</html>`))

var tagPage = template.Must(template.New("tag").Parse(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta http-equiv="x-ua-compatible" content="ie=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{{.Name}}</title>
  <link rel="alternate" href="feed.atom" type="application/atom+xml" />
	<style>
		body {
			color: #3c3c3c;
			font-family: -apple-system, BlinkMacSystemFont, "Avenir Next", "Avenir", "Segoe UI", "Lucida Grande", "Helvetica Neue", "Helvetica", "Fira Sans", "Roboto", "Noto", "Droid Sans", "Cantarell", "Oxygen", "Ubuntu", "Franklin Gothic Medium", "Century Gothic", "Liberation Sans", sans-serif;
			font-size: 16px;
			line-height: 22px;
			-webkit-font-smoothing: antialiased;
		}

		a,
		a:visited,
		a:hover,
		.index-article__link:hover {
			border-bottom-color: #da393f;
			border-bottom-style: solid;
			border-bottom-width: 1px;
			color: #3c3c3c;
			text-decoration: none;
			text-decoration-skip: ink;
		}

		a:hover {
			color: #da393f;
		}

		.container {
			margin: 1.5rem 1rem;
			max-width: 700px;
		}

		@media all and (max-width: 575px) {
			.container {
				margin: 1rem 0;
			}
		}

		article,
		main {
			margin: 1.5rem 0;
		}

		.index-article {
			margin: 1rem 0;
		}

		.index-article__link {
			border-bottom: none;
			font-size: 18px;
			font-weight: bold;
			line-height: 22px;
			margin: 0;
		}

		.index-article__link:hover {
			color: #3c3c3c;
		}

		.lede {
			margin: 20px 0;
		}

		.lede__headline {
			font-size: 32px;
			line-height: 38px;
			margin: 0;
		}
	</style>
  <link rel="icon" href="data:;base64,iVBORw0KGgo=">
</head>
<body>
  <div class="container">
    <nav>
      <a href="/">
        {{.Site.Name}} &larr;
      </a>
    </nav>

    <article>
      <header class="lede">
        <h1 class="lede__headline">{{.Name}}</h1>
      </header>
    </article>

    <main>
      {{- range .Articles }}
        <div class="index-article">
          <a href="/{{.ID}}" class="index-article__link">
            {{.Title}}
          </a>

          <div class="index-article__byline">
            <time datetime="{{.LastUpdated}}" class="index-article__published-on">
              {{.LastUpdatedIn}}
            </time>
          </div>
        </div>
      {{- end }}
    <main>
  </div>
</body>
</html>`))
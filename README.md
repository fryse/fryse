# Fryse

[![Build Status](https://travis-ci.org/fryse/fryse.svg?branch=master)](https://travis-ci.org/fryse/fryse)

> Fryse is a Static Site Generator written in Elixir which aims to be generic and scriptable

## Installation

Make sure you have Elixir installed (1.5 or newer) and that `~/.mix/escripts` is in your PATH variable.

```
mix escript.install hex fryse
```

## Quickstart

Bootstrap a new project:

```
fryse new blog
cd blog
```

Generate site:

```
fryse build
```

Run generated site locally:

```
fryse serve
```

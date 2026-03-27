--------------------------------------------------
AGENT
--------------------------------------------------

You are a senior WordPress developer working on a block-based theme project (Ollie).

Be concise. Do not overengineer. Solve the task directly.

--------------------------------------------------
PROJECT CONTEXT
--------------------------------------------------

- This repo contains ONLY `wp-content`
- WordPress core runs inside the DevContainer
- Stack: WordPress + Block Theme (Ollie) + Composer (WPackagist)

--------------------------------------------------
ENVIRONMENT RULES
--------------------------------------------------

- Always assume DevContainer environment
- PHP, MySQL, Node are provided by the container
- Do not rely on host machine setup

--------------------------------------------------
WP-CLI RULE (CRITICAL)
--------------------------------------------------

WordPress is installed at:

/var/www/html

All WP-CLI commands MUST include:

--path=/var/www/html

Example:
wp plugin activate wordpress-seo --path=/var/www/html

--------------------------------------------------
DEPENDENCIES
--------------------------------------------------

- Plugins MUST be installed via Composer (WPackagist)
- Never download plugins manually

Example:
composer require wpackagist-plugin/wordpress-seo

--------------------------------------------------
GIT RULES
--------------------------------------------------

- Always branch from `main`
- Naming:
  - feature/*
  - fix/*
  - chore/*
  - refactor/*

- Use conventional commits:
  feat:
  fix:
  chore:
  refactor:

--------------------------------------------------
CODING RULES
--------------------------------------------------

PHP:
- Follow WordPress Coding Standards
- Use short arrays []
- Prefer WordPress APIs over custom logic

JS:
- ES6+
- const / let only
- No var

Formatting:
- Tabs
- Single quotes
- No semicolons

--------------------------------------------------
DO NOT
--------------------------------------------------

- Do not change DevContainer config unless explicitly asked
- Do not introduce new tools
- Do not modify project structure
- Do not assume WordPress is in project root
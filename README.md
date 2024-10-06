# README

This is a scraper that runs on [Morph](https://morph.io).
To get started [see the documentation](https://morph.io/documentation)

* Previously a civica based site, discontinued 28 Oct 2023 
  as documented by [City of Whittlesea - Issue #849](https://github.com/planningalerts-scrapers/issues/issues/849)

## Installing

Select ruby using your favourite ruby version manager, for example:
```shell
chruby 3.2.5
```

Then install gems using bundler. Currently morph.io has bundler v1.15.2 installed,
so you need to force the installation and use of earlier version.
Ignore the warnings to upgrade bundler till morph.io ruby runners are updated.

`
gem install bundler -v 1.15.2
bundle _1.15.2_ install
`

## Running scraper

`
bundle exec ruby scraper.rb 
`

## Useful links

* [Main Site](https://www.whittlesea.vic.gov.au/Home) 
  / Services 
  / Building, planning and development 
  / Planning 
  / Planning services and online forms 
  / Online planning application portal 
  -> [online planning application portal](https://online.whittlesea.vic.gov.au/s/permit-required) 
  which presents apply for permit link form
  * [Home](https://online.whittlesea.vic.gov.au/s/) (Home of the online portal)
    * [Planning Services & Register](https://online.whittlesea.vic.gov.au/s/publicregister) - search form for Planning Register
 

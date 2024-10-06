# README

This is a scraper that runs on [Morph](https://morph.io).
To get started [see the documentation](https://morph.io/documentation)

* Previously a civica based site, discontinued 28 Oct 2023 
  as documented by [City of Whittlesea - Issue #849](https://github.com/planningalerts-scrapers/issues/issues/849)

## Installing

Select ruby using your favourite ruby version manager, for example:
```shell
chruby 3.3.5
```

Then install gems using bundler
`
bundle install
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
 
 ## Dom tree

```shell
c-search-public-register # .
  [SHADOW-ROOT]
    lightning-layout # .slds-grid.slds-wrap
      slot # .slds-slot
        lightning-layout-item # .slds-size_8-of-12
          [SHADOW-ROOT]
            slot # .
              div # .page-instructions
                div # .slds-grid
                  lightning-icon # .slds-icon-utility-info-alt.slds-icon_container
                    [SHADOW-ROOT]
                      span # .
                        lightning-primitive-icon # .
                          [SHADOW-ROOT]
                            svg # .slds-icon.slds-icon-text-default.slds-icon_small
                              g #
                                path #
                          svg # .slds-icon.slds-icon-text-default.slds-icon_small
                            g #
                              path #
                        span # .slds-assistive-text
                    span # .
                      lightning-primitive-icon # .
                        [SHADOW-ROOT]
                          svg # .slds-icon.slds-icon-text-default.slds-icon_small
                            g #
                              path #
                        svg # .slds-icon.slds-icon-text-default.slds-icon_small
                          g #
                            path #
                      span # .slds-assistive-text
                  span # .slds-page-header__title.slds-p-horizontal_xx-small
                div # .slds-p-left_small
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                        a # .page-ins-url
                  div # .slds-grid.page-ins-lines
                    div # .
                      p # .
                    div # .
                      p # .
                        a # .page-ins-url
          slot # .
            div # .page-instructions
              div # .slds-grid
                lightning-icon # .slds-icon-utility-info-alt.slds-icon_container
                  [SHADOW-ROOT]
                    span # .
                      lightning-primitive-icon # .
                        [SHADOW-ROOT]
                          svg # .slds-icon.slds-icon-text-default.slds-icon_small
                            g #
                              path #
                        svg # .slds-icon.slds-icon-text-default.slds-icon_small
                          g #
                            path #
                      span # .slds-assistive-text
                  span # .
                    lightning-primitive-icon # .
                      [SHADOW-ROOT]
                        svg # .slds-icon.slds-icon-text-default.slds-icon_small
                          g #
                            path #
                      svg # .slds-icon.slds-icon-text-default.slds-icon_small
                        g #
                          path #
                    span # .slds-assistive-text
                span # .slds-page-header__title.slds-p-horizontal_xx-small
              div # .slds-p-left_small
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                      a # .page-ins-url
                div # .slds-grid.page-ins-lines
                  div # .
                    p # .
                  div # .
                    p # .
                      a # .page-ins-url
        lightning-layout-item # .slds-p-top_medium.slds-size_12-of-12
          [SHADOW-ROOT]
            slot # .
              div # .page-header.slds-grid
                h1 # .
                lightning-button-icon # .help-text
                  [SHADOW-ROOT]
                    button # .slds-button.slds-button_icon.slds-button_icon-bare.slds-button_icon-inverse
                      lightning-primitive-icon # .
                        [SHADOW-ROOT]
                          svg # .slds-button__icon
                            g #
                              path #
                        svg # .slds-button__icon
                          g #
                            path #
                  button # .slds-button.slds-button_icon.slds-button_icon-bare.slds-button_icon-inverse
                    lightning-primitive-icon # .
                      [SHADOW-ROOT]
                        svg # .slds-button__icon
                          g #
                            path #
                      svg # .slds-button__icon
                        g #
                          path #
          slot # .
            div # .page-header.slds-grid
              h1 # .
              lightning-button-icon # .help-text
                [SHADOW-ROOT]
                  button # .slds-button.slds-button_icon.slds-button_icon-bare.slds-button_icon-inverse
                    lightning-primitive-icon # .
                      [SHADOW-ROOT]
                        svg # .slds-button__icon
                          g #
                            path #
                      svg # .slds-button__icon
                        g #
                          path #
                button # .slds-button.slds-button_icon.slds-button_icon-bare.slds-button_icon-inverse
                  lightning-primitive-icon # .
                    [SHADOW-ROOT]
                      svg # .slds-button__icon
                        g #
                          path #
                    svg # .slds-button__icon
                      g #
                        path #
        lightning-layout-item # .slds-size_12-of-12
          [SHADOW-ROOT]
            slot # .
              lightning-layout # .slds-grid
                [SHADOW-ROOT]
                  slot # .slds-slot
                    lightning-layout-item # .slds-p-around_small.slds-size_5-of-12
                      [SHADOW-ROOT]
                        slot # .
                          lightning-input # .AppNo.slds-form-element
                            [SHADOW-ROOT]
                              lightning-primitive-input-simple # .
                                div # .
                                  label # .slds-form-element__label.slds-no-flex
                                    slot # .
                                      slot # .
                                  div # .slds-form-element__control.slds-grow
                                    input #input-18 .slds-input
                            lightning-primitive-input-simple # .
                              [SHADOW-ROOT]
                                div # .
                                  label # .slds-form-element__label.slds-no-flex
                                    slot # .
                                      slot # .
                                  div # .slds-form-element__control.slds-grow
                                    input #input-18 .slds-input
                              div # .
                                label # .slds-form-element__label.slds-no-flex
                                  slot # .
                                    slot # .
                                div # .slds-form-element__control.slds-grow
                                  input #input-18 .slds-input
                      slot # .
                        lightning-input # .AppNo.slds-form-element
                          [SHADOW-ROOT]
                            lightning-primitive-input-simple # .
                              div # .
                                label # .slds-form-element__label.slds-no-flex
                                  slot # .
                                    slot # .
                                div # .slds-form-element__control.slds-grow
                                  input #input-18 .slds-input
                          lightning-primitive-input-simple # .
                            [SHADOW-ROOT]
                              div # .
                                label # .slds-form-element__label.slds-no-flex
                                  slot # .
                                    slot # .
                                div # .slds-form-element__control.slds-grow
                                  input #input-18 .slds-input
                            div # .
                              label # .slds-form-element__label.slds-no-flex
                                slot # .
                                  slot # .
                              div # .slds-form-element__control.slds-grow
                                input #input-18 .slds-input
                    lightning-layout-item # .slds-p-around_small.slds-size_5-of-12
                      [SHADOW-ROOT]
                        slot # .
                          lightning-input # .parAppNo.slds-form-element
                            [SHADOW-ROOT]
                              lightning-primitive-input-simple # .
                                div # .
                                  label # .slds-form-element__label.slds-no-flex
                                    slot # .
                                      slot # .
                                  div # .slds-form-element__control.slds-grow
                                    input #input-21 .slds-input
                            lightning-primitive-input-simple # .
                              [SHADOW-ROOT]
                                div # .
                                  label # .slds-form-element__label.slds-no-flex
                                    slot # .
                                      slot # .
                                  div # .slds-form-element__control.slds-grow
                                    input #input-21 .slds-input
                              div # .
```
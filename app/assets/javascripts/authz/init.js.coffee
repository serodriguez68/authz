class Page
  controller: () ->
    $('meta[name=page-specific-javascript]').attr('controller')
  action: () ->
    $('meta[name=page-specific-javascript]').attr('action')
  module: () ->
    $('meta[name=page-specific-javascript]').attr('module')

@page = new Page

$(document).ready(function() {
  if (page.controller() == 'roles' && (page.action() == 'new' || page.action() == 'edit')) {

    $('form').validate()
    $('#role_name').rules('add',{
      messages: {
        remote: 'This role name already exists'
      },
      remote: {
        url: $('#role_name').data('validation-path'),
        type: 'get'
      }
    })
    $('.j-multiselectable').multiSelect(window.quicksearchConfig.init)
  }
})

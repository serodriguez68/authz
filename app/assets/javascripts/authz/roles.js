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

    $('#role_business_process_ids').multiSelect(window.quicksearchConfig.init)
    $('#role_role_grant_ids').multiSelect(window.quicksearchConfig.init)
    $('#role_user_ids').multiSelect(window.quicksearchConfig.init)

  }
})

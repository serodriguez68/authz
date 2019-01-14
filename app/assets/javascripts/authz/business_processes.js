$(document).ready(function() {
  if (page.controller() == 'business_processes' && (page.action() == 'new' || page.action() == 'edit')) {
    $('form').validate()

    $('#business_process_name').rules('add',{
      messages: {
        remote: 'This process name already exists'
      },
      remote: {
        url: $('#business_process_name').data('validation-path'),
        type: 'get'
      }
    })

    $('#business_process_role_ids').multiSelect(window.quicksearchConfig.init)
    $('#business_process_controller_action_ids').multiSelect(window.quicksearchConfig.init)

  }
})

$(document).ready(function() {
  if (page.controller() == 'controller_actions' && (page.action() == 'new') || (page.action() == 'edit' || page.action() == 'create' || page.action() == 'update')) {
    $('form').validate()
    $('#controller_action_controller').rules('add',{
      messages: {
        remote: 'This controller name does not exist'
      },
      remote: {
        url: $('#controller_action_controller').data('validation-path'),
        type: 'get'
      }
    })
    $('#controller_action_action').rules('add',{
      messages: {
        remote: 'This action name does not exist for this controller'
      },
      remote: {
        url: $('#controller_action_action').data('validation-path'),
        type: 'get',
        data: {
          controller_name: function(){
            return $('#controller_action_controller').val()
          }
        }
      }
    })

    $('#controller_action_business_process_ids').multiSelect(window.quicksearchConfig.init)

  }
})

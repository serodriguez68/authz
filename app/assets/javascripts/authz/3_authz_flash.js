$(document).ready(function() {
  $('.az-flash').addClass('is-active')
  $('.az-flash-close').click(function(){
    $(this).parent().removeClass('is-active')
  })
})

window.azFlash = {
  init: function(){
    $('.az-flash').addClass('is-active')
    this.bindClickToClose();
    window.setTimeout(function(){
      $('.az-flash').removeClass('is-active')
    }, 6000)
  },
  bindClickToClose: function(){
    $('.az-flash-close').click(function(){
      $(this).parent().removeClass('is-active')
    })
  }
}

$(document).ready(function() {
  window.azFlash.init()
})

#= require unobtrusive_flash
#= require toastr

jQuery ->
  toastr.options =
    positionClass: 'toast-top-right'
    closeButton: true
    progressBar: true
    showMethod: 'fadeIn'
    hideMethod: 'fadeOut'
    showEasing: 'swing'
    hideEasing: 'linear'
    showDuration: 300
    hideDuration: 1000
    extendedTimeOut: 1000
    timeOut: 1500

  flashHandler = (e, params) ->
    message = params.message
    type = params.type

    if message
      message = message.replace /\+/g, ' '

      if type == 'error'
        toastr.error message, 'Error'
      else if type == 'alert'
        toastr.warning message, 'Warning'
      else
        toastr.success message, ''

  $(window).bind('rails:flash', flashHandler)

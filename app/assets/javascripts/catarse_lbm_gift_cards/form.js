$("#catarse_lbm_gift_cards_form #accept_terms").live('change', function(){
  submit = $("#catarse_lbm_gift_cards_form input[type=submit]")
  console.log(submit)
  if ($(this).is(':checked')) {
    submit.attr('disabled', false)
    submit.removeClass('disabled')
  } else {
    submit.attr('disabled', true)
    submit.addClass('disabled')
  }
})

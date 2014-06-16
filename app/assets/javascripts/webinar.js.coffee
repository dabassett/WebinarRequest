# woo jquery/coffeescript
#$ = JQuery

$ ->

  # hide the discount_owner field unless discount is checked
  $('#discount-owner-field').hide()
  $('#discount-checkbox').change ->
    if this.checked then $('#discount-owner-field').show() else $('#discount-owner-field').hide()

  # make a generic datepicker with corrected alt field for rails forms
  $('.jq-datepicker').datepicker(
    dateFormat: 'yy-mm-dd'
  )

  # tooltip on request form
  $('#request_requester_email').tooltip()

  # tabs and accordions on the admin page
  $('.tabs').tabs()
  $('.review-accordion').accordion(
    heightStyle: 'content'
  )

  # jquery ui buttons
  $(':submit, a.button, button').button()

  # fun button icons
  $('.approve').button(
    icons:
      primary: 'ui-icon-check'
  )
  $('.deny').button(
    icons:
      primary: 'ui-icon-close'
  )
  $('.edit').button(
    icons:
      primary: 'ui-icon-document'
  )
  $('.show').button(
    icons:
      primary: 'ui-icon-info'
  )
  $('.delete').button(
    icons:
      primary: 'ui-icon-trash'
  )

  # use uniformjs for other form elements
  $(':text, :checkbox, select, textarea').uniform()
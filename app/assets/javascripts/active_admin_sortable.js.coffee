# http://stackoverflow.com/a/8936202
#
# ActiveAdmin already includes the necessary jquery in active_admin/base,
# so just add this to javascripts/active_admin.js after //= require active_admin/base
# 
# 
# Serialize and Sort 
# 
# model_name - you guessed it, the name of the model we are calling sort on.
#              This is the actual variable name, no need to change it.
#
sendSortRequestOfModel = (model_name) ->
  formData = $('#index_table_' + model_name + ' tbody').sortable('serialize')
  formData += '&' + $('meta[name=csrf-param]').attr('content') + 
    '=' + encodeURIComponent($('meta[name=csrf-token]').attr('content'))
  $.ajax
    type: 'post'
    data: formData
    dataType: 'script'
    url: '/admin/' + model_name + '/sort'
 
# Don't forget we are sorting Duck, so ducks refers specifically to that.
#
jQuery ($) ->
  if $('body.admin_venues.index').length
    $( '#index_table_venues tbody' ).disableSelection()
    $( '#index_table_venues tbody' ).sortable
      axis: 'y'
      cursor: 'move'
      update: (event, ui) ->
        sendSortRequestOfModel('venues')
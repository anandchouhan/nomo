# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


window.NF = do (NF = window.NF || {}) ->

  NF.Comments =
    init: ->
      @initializeSubmission()
      @commentHover()
      @showLikes()

    initializeSubmission: ->
      $('.comments :submit').click (e) ->
        $(".messages-block").scrollTop(-99999)
        btn = $(@)
        btn.addClass('disabled', true)
        NF.Comments.removeDuplicateDetails()
        setTimeout ->
          btn.removeClass('disabled')
        , 2500

    refresh: ->
      $('a.comments-liked').click ->
        console.log 'Clicked?'
        NF.Comments.removeDuplicateDetails()

    removeDuplicateDetails: ->
      lastElementId = null
      lastElement = null
      $('.col-sm-12 .comment').each (index) ->
        currentElementId = $(this).children().filter('.message-details').data('id')
        if (currentElementId == lastElementId)
          if (lastElement != undefined)
            lastElement.children().filter('.message-time')
          lastElement.children().filter('.message-user').hide()

        lastElement = $(this)
        lastElementId = currentElementId
        return

    commentHover: ->
      $('.message-body').hover (->
        item = $(this).children().filter('.comment-likes')
        if (item.is(":hidden"))
          item.removeAttr('hidden')
      ), ->
        item = $(this).children().filter('.comment-likes')
        value = item.children().filter('.number').text()
        if ((parseInt(value) == 0) && (item.is(":visible")))
          item.attr('hidden', true)
      return

    showLikes: ->
      $('.comment-likes').each (index) ->
        element = $(this)
        value = $(this).children().filter('span').text()
        if (parseInt(value) > 0)
          element.removeAttr('hidden')

  return NF

$(document).ready ->
  NF.Comments.init()
  return

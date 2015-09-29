#=require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.application.show_available_thumbnails', ->

  thereIsAtLeastOneVisibleThumbnailWithNonZeroSize = (domElement) ->
    amazonThumbnailsWithNonZeroSize = $.grep $(domElement).find('.amazon-thumbnail'), (amazonThumbnail) ->
      $(amazonThumbnail).find('img').width() > 1

    amazonThumbnailsWithNonZeroSize.length > 0

  # when all images are loaded (we need this do determine if a amazon thumbnail is valid or not; the urls are always valid, but sometimes the give 1px images)
  imagesLoaded 'body', ->
    $('.record').each (index, record) ->
      recordThumbnails = $(record).find('.record-thumbnail')

      if thereIsAtLeastOneVisibleThumbnailWithNonZeroSize(recordThumbnails)
        $(recordThumbnails).find('.amazon-thumbnail').each (index, amazonThumbnail) ->
          $(amazonThumbnail).siblings().hide()
          $(amazonThumbnail).find('img').css('width', '100%').show()
      else
        $(record).find('.default-thumbnail *').show()


    $('.record-details').each (index, recordDetails) ->
      recordThumbnails = $(recordDetails).find('.record-thumbnail')

      if thereIsAtLeastOneVisibleThumbnailWithNonZeroSize(recordThumbnails)
        $(recordThumbnails).each (index, recordThumbnail) ->
          $(recordThumbnail).find('.amazon-thumbnail').each (index, amazonThumbnail) -> $(amazonThumbnail).find('img').css('width', '100%').show()
          $(recordThumbnail).prevAll('div[class*=span]').last().addClass('span10').removeClass('span12')
          $(recordThumbnail).addClass('span2')
      else
        $(recordThumbnails).hide()

    # we need this in order to truncate after images are loaded (and spans are resized)
    $('.trunker').trunker()

#= require utils/singletonReadyOrPageChange

app.utils.singletonReadyOrPageChange 'app.views.records.show.processGoogleBooksApiRequests', ->
  handleError = ->
    # maybe we want to handle this later

  isbnOf = (item) ->
    isbn = null
    $.each item?.volumeInfo?.industryIdentifiers, (index, value) ->
      isbn = value.identifier if value.type is "ISBN_10" || !(isbn?) # isbn_10 rules them all for now
    return isbn

  isViewable = (item) ->
    viewability = item?.accessInfo?.viewability.toLowerCase()
    (viewability?.indexOf('all_pages') == 0 || viewability?.indexOf('partial') == 0) || false

  setupGoogleViewer = ->
    google.load 'books', '0', 'callback': ->
      $('a[data-toggle="tab"]').on 'shown', (e) ->
        if $(e.target).attr('href') == "#tab1-3"
          viewer = new google.books.DefaultViewer(document.getElementById('google-books-viewer'))
          isbn = $('#google-books-viewer').data('isbn')
          viewer.load "ISBN:#{isbn}", null, ->
            # when the viewer is initialized, resize it slightly to hide the height scroll bars (they are shown, regardless which size the div has)
            if (matchResult = $('#google-books-viewer').css('height').match(/\d*/))?
              currentHeight = parseInt(matchResult[0])
              $('#google-books-viewer').css('height', "#{currentHeight + 30}px")

  requestUrl = $('#google-books-api-request-url').text()

  if requestUrl?.length > 0
    $.jsonp
      url: requestUrl,
      callbackParameter: 'callback',
      success: (data) =>
        if !data.error? && data.totalItems > 0
          # add link to google books
          if (infoLinkUrl = data.items[0].volumeInfo?.infoLink)?
            $('.google-books-link').each (index, googleBooksLink) ->
              $(googleBooksLink).replaceWith """
                <tr>
                  <td class="key">Externer Link</td>
                  <td class="value"><a href=\"#{infoLinkUrl}\" target=\"_blank\">Dieses Buch bei Google Books <i class="fa fa-signout"></i></a></td>
                </tr>
              """

          # add preview tab
          if isViewable(data.items[0]) && google?
            $('#google-books-preview-nav-tab').replaceWith("<li><a href=\"#tab1-3\" data-toggle=\"tab\">Leseprobe</a></li>")
            $('#google-books-preview-tab-content').replaceWith """
              <div id=\"tab1-3\" class=\"tab-pane\">
                <div class=\"row-fluid\">
                  <div class=\"span12\">
                    <div id=\"google-books-viewer\" data-isbn=\"#{isbnOf(data.items[0])}\" style=\"height: 500px;\"></div>
                  </div>
                </div>
              </div>
            """

            setupGoogleViewer()
        else
          # api call failed (e.g. isbn unknown or api limit exceeded
          handleError()
  else
    # no request url given
    handleError()

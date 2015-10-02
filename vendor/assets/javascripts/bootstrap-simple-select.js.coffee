($ = jQuery).fn.extend
  bootstrapSimpleSelect: (options) ->

    dropdownHtml = (selectElement) ->
      optionElements = selectElement.find("option")
      selectedOptionElement = selectElement.find("option:selected")
      
      """
        <div class="btn-group bootstrap-simple-select">
          #{dropdownButtonHtml(selectedOptionElement)}
          #{dropdownMenuHtml(optionElements)}
        </div>
      """

    dropdownButtonHtml = (selectedOptionElement) ->
      """<button class="btn btn-default dropdown-toggle" data-toggle="dropdown" data-value="#{selectedOptionElement.val()}">#{dropdownButtonTextHtml($(selectedOptionElement).text())}</button>"""

    dropdownButtonTextHtml = (buttonText) ->
      # one has to be carefull about linebreaks within the button element, because these may enlarge the space between text and caret
      """<span>#{buttonText}</span><span>&nbsp;</span><span class="caret"></span>"""

    dropdownMenuHtml = (optionElements) ->
      """<ul class="dropdown-menu" role="menu">#{($.map(optionElements, dropdownMenuElementHtml)).join('')}</ul>"""

    dropdownMenuElementHtml = (element) ->
      """<li><a tabindex="-1" href="#" data-value="#{$(element).val()}">#{$(element).text()}</a></li>"""

    registerEventHandlers = (select, dropdown) ->

      handleListItemClick = (e) ->
        e.preventDefault()

        associatedDropdown = $(e.currentTarget).closest('.btn-group')
        associatedSelectElement = $(e.currentTarget).closest('.btn-group').prev('select')
        indexOfClickedDropdownMenuElement = $(e.currentTarget).parent('ul').find('li').index(e.currentTarget)
        
        newlySelectedOptionElement = associatedSelectElement.find('option').removeAttr('selected').eq(indexOfClickedDropdownMenuElement).prop('selected', true).attr('selected', 'selected')
        associatedDropdown.find('button').replaceWith(dropdownButtonHtml(newlySelectedOptionElement))

        # jquery trigger will only trigger jquery events, but some libraries (ractive) use native dom events
        # associatedSelectElement.trigger('change')
        if associatedSelectElement[0].fireEvent # < IE9
          associatedSelectElement[0].fireEvent("onchange")
        else
          associatedSelectElement[0].dispatchEvent(new Event("change"))

      handleSelectChange = (e) =>
        selectElement = $(e.currentTarget)
        associatedDropdown = $(e.currentTarget).next('.bootstrap-simple-select')
        indexOfSelectedOption = selectElement.find('option').index(selectElement.find('option:selected'))

        associatedDropdown.find('button').html(dropdownButtonTextHtml(associatedDropdown.find('li a').eq(indexOfSelectedOption).text()))
        associatedDropdown.change()

      dropdown.on 'click', 'li', handleListItemClick
      select.on 'change', handleSelectChange
    
    return @each () ->
      if $(@).next('.btn-group, bootstrap-simple-select').length == 0
        $(@).after(dropdown = $(dropdownHtml($(@)))).css('display', 'none')
        registerEventHandlers($(@), dropdown)

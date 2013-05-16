###
  yawords
  Букмарклет для повторения слов из Тетрадок Яндекс.Словарей
  https://github.com/avrelian/yawords

  Copyright 2013, Sergey Radchenko
  avrelian@yandex.ru
  avrelian234567@gmail.com
  http://www.facebook.com/Sergey.G.Radchenko

  Released under the MIT, BSD, and GPL Licenses.

  Date: 2013-05-16 19:17:00 +0400
###

do ($ = jQuery) ->

  [LANG_FROM, LANG_TO, SOME_CODE, WORD, TRANSLATION, DICTIONARY] = [0..5]
  KEY_CODE_ENTER = 13
  QUESTION_ROWS_SELECTOR = '.b-simple-test__question:not(.b-simple-test__question_correct_yes, .b-simple-test__question_correct_no)'

  currentTestType = null
  words = []
  testWords =
    text: []
    audio: []
  ui =
    text: {}
    audio: {}
  $rows =
    text: []
    audio: []


  random = (range, start = 0) ->
    Math.floor(Math.random() * range + start)

  capitalize = (str) ->
    str.charAt(0).toUpperCase() + str.slice(1)

  initTest = (type) ->

    currentTestType = type

    NUM_ROWS = 10

    selectWords = ->
      testWords[type] = []
      testWords[type].push(words.splice(random(words.length), 1)[0]) for [0...Math.min(NUM_ROWS, words.length)]
      words = words.concat(testWords[type])

    render = ->
      getRowHtml = (num, word) ->
        """
          <li class="b-simple-test__question">
            <span class="yawords-word-num">#{num}</span>.
            <span class="b-simple-test__word">#{if type == 'text' then word[WORD] else getAudio(word)}</span>
            <span class="b-simple-test__answer"></span>
          </li>
        """

      getAudio = (word) ->
        """
          <img class="b-icon b-icon_type_audio audio" src="//yandex.st/lego/_/La6qi18Z8LwgnZdsAr1qy1GwCwo.gif" alt="Прослушать" title="Прослушать">
          <span class="b-link b-link_pseudo_yes audio" data-word="#{word[WORD]}">прослушать</span>
        """

      rowsHtml = ''
      for word, index in testWords[type]
        rowsHtml += getRowHtml(index + 1, word)
      ui[type].rowsContainer.html(rowsHtml)

      ui[type].el.append(ui[type].rowsContainer)

      $rows[type] =
        ui[type].rowsContainer.find('.b-simple-test__question')
          .addClass('b-link_pseudo_yes').css('overflow': 'hidden')
          .click( (ev) ->
            $row = $(ev.target).closest(QUESTION_ROWS_SELECTOR)
            if $row.length
              unselectRow()
              selectRow($row)

            if getCurrentTestType() == 'audio'
              word = getTestWordByRow($row)
              $(window).triggerHandler("b-playsound", [
                "Sound#{capitalize(word[LANG_FROM])}/#{encodeURIComponent(word[WORD])}"
                -> $row.fadeTo("fast", 0.2)
                -> $row.fadeTo("fast", 1)
              ])
            false
          )

    selectWords()
    render()
    selectRow()

    currentTestType = null


  checkAnswer = (type = getCurrentTestType()) ->

    showAnswer = (matches) ->
      $currentRow
        .addClass("b-simple-test__question_correct_#{if matches then 'yes' else 'no'}")
        .find('.b-simple-test__answer')
          .text(if matches then matches.join(', ') else testWord[TRANSLATION])

      if type == 'audio'
        $audioLink = $currentRow.find('.b-link.b-link_pseudo_yes.audio')
        $audioLink.replaceWith($audioLink.data('word'))

    getMatches = (testWord, userInput) ->

      translations = $.map(testWord[TRANSLATION].split(','), $.trim)
      userVariants = $.map(userInput.split(','), $.trim)

      $.grep(translations, (translation) ->
        $.grep(userVariants, (userVariant) ->
          translation == userVariant
        ).length
      )

    $currentRow = getCurrentRow()

    testWord = getTestWordByRow()

    matches = getMatches(testWord, ui[type].input.val())

    if matches.length
      showAnswer(matches)
    else
      showAnswer()

    ui[type].input.val('')

    unselectRow()

    $nextRow = getNextRow()
    if $nextRow.length
      selectRow($nextRow)
    else
      ui[type].control.hide()
      ui[type].moreControl.show()

    false

  bindUI = ($el, type) ->
    ui[type] =
      el: $el
      rowsContainer: $el.find('ul')
      control: $el.find('.b-simple-test__controls')
      input: $el.find('.b-simple-test__controls .b-simple-test__input .b-form-input__input')
      giveAnswerButton: $el.find('.b-simple-test__buttons .b-form-button:eq(0)')
      giveUpButton: $el.find('.b-simple-test__buttons .b-form-button:eq(1)')
      moreControl: $el.find('.b-simple-test__more')
      startOverButton: $el.find('.b-simple-test__more .b-link')

    ui[type].input.off('keyup').keyup( (ev) ->
      checkAnswer() if ev.keyCode == KEY_CODE_ENTER and getCurrentRow().length
    )

    ui[type].giveAnswerButton.click( -> checkAnswer() )

    ui[type].giveUpButton.click( -> checkAnswer() )

    ui[type].startOverButton.click( -> initTest(getCurrentTestType()) )



  getCurrentTestType = ->
    if currentTestType
      currentTestType
    else
      if $('.b-tabbed-pane__panel_state_current .b-simple-test').is('.b-simple-test_type_audio')
        'audio'
      else
        'text'

  getCurrentRow = ->
    $rows[getCurrentTestType()].filter('.b-simple-test__question_current_yes')

  getNextRow = ->
    $rows[getCurrentTestType()].filter(QUESTION_ROWS_SELECTOR).first()

  selectRow = ($row = getNextRow()) ->
    $row
      .addClass('b-simple-test__question_current_yes')
      .removeClass('b-link_pseudo_yes')
      .find('.b-simple-test__answer')
        .text('ваш перевод?')

  unselectRow = ($row = getCurrentRow()) ->
    $row
      .removeClass('b-simple-test__question_current_yes')
      .addClass('b-link_pseudo_yes')

    $row.filter(QUESTION_ROWS_SELECTOR)
      .find('.b-simple-test__answer')
        .text('')

  getTestWordByRow = ($row = getCurrentRow()) ->
    type = getCurrentTestType()
    testWords[type][$rows[type].index($row)]


  loadWords = ->

    $el = $('<div>')

    getCurrentNotebookId = ->
      $('.b-menu__item_kind_record-to .b-form-select__select').val() || 0

    getUrl = ->
      "/~p/#{encodeURIComponent('~тетрадки')}/#{getCurrentNotebookId()}"

    $el.load(getUrl(), rnd: Math.random(), ->
      words = $el.find('.b-notebook.i-bem').data('words')
      initTest('text')
      initTest('audio')
    )


  $('body').on('click', '.i-popup .b-form-select__text', ->
    setTimeout(loadWords, 100)
  )

  bindUI($('.b-simple-test_type_text'), 'text')
  bindUI($('.b-simple-test_type_audio'), 'audio')

  loadWords()
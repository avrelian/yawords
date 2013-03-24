# yawords
# Букмарклет для повторения слов из Тетрадок Яндекс.Словарей
# https://github.com/avrelian/yawords
#
# Copyright 2013, Sergey Radchenko
# avrelian@yandex.ru
# avrelian234567@gmail.com
# http://www.facebook.com/Sergey.G.Radchenko
#
# Released under the MIT, BSD, and GPL Licenses.
#
# Date: 2013-03-24 14:41:14 +0400

do ($ = jQuery) ->
  $el = $('<div>')
  words = []

  [LANG_FROM, LANG_TO, SOME_CODE, WORD, TRANSLATION, DICTIONARY] = [0..5]

  getUrl = (notebookId = 0) ->
    "/~p/#{encodeURIComponent('~тетрадки')}/#{notebookId}"

  loadWords = (notebookId = 0) ->
    $el.load(getUrl(notebookId), rnd: Math.random(), onLoadWords)

  onLoadWords = ->
    words = $el.find('.b-notebook.i-bem').data('words')
    console.log(words)

  loadWords(1325505601)
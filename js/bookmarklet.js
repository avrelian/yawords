/*
 * yawords
 * Букмарклет для повторения слов из Тетрадок Яндекс.Словарей
 * https://github.com/avrelian/yawords
 *
 * Copyright 2012, Sergey Radchenko
 * avrelian@yandex.ru
 * avrelian234567@gmail.com
 * http://www.facebook.com/Sergey.G.Radchenko
 *
 * Released under the MIT, BSD, and GPL Licenses.
 *
 * Date: 2012-01-04 14:41:14 +0400
 */

(function($, slovari, lego){

    var yawords;
    var jC = $('.b-test-container');
    var numWords = 5;

    var getBody = function(func){
        var s = func.toString();
        return s.substring(s.indexOf('{') + 1, s.lastIndexOf('}'));
    };

    $.getScript('http://yandex.st/v-64/slovari-ng/js/_notebooks.js', function(){
        yawords = new new Function('' + getBody(slovari.NotebookBackend) + ' ; this.getNotebooks = f;');
        yawords.getNotebooks();
    });

    var update = function(){
        var words = yawords.getNotebook().words;
        for(var lang in slovari.Data.LangToAdjective){
            slovari.Data.simpleTest[lang] = [];
        }
        for(var i = 0, ii = words.length; i < ii; i++){
            var word = words[i];
            var translations = word.translation.split(',');
            $.each(translations, function(index, translation){
                translations[index] = $.trim(translation);
            });
            slovari.Data.simpleTest[word.lang].push({
                c: word.id, // id
                q: word.title, // слово
                a: translations  // массив переводов
            });
        }
        for(var lang in slovari.Data.simpleTest){
            if(slovari.Data.simpleTest[lang].length < numWords){
                delete slovari.Data.simpleTest[lang];
            }
        }
        slovari.Data.audioTest = slovari.Data.simpleTest;
    };

    var renderNotebookLinks = function(){
        var html = '';
        var notebooks = yawords.getNotebooksAsArray();
        $.each(notebooks, function(index, notebook){
            if(notebook.length >= numWords){
                html += '' +
                    '<li>' +
                    '<a class="b-pseudo-link ' + (notebook.active ? 'yawords-active' : '') + '" id="yawords-' + notebook.id + '" href="javascript:void(0)">' +
                    notebook.escapedName + ' (' + notebook.length + ')' +
                    '</a>' +
                    '</li>';
            }
        });
        return html;
    };

    var refresh = function(){
        $('.b-test__more__link', jC).click();
    };

    $('.b-test', jC).before('<style>.yawords-active { font-weight: bolder; }</style><ul class="yawords-links"></ul>');

    $(slovari).bind("redraw.Backend.Slovari", function(){
        $('.yawords-links', jC).html(renderNotebookLinks());
        var jLinks = $('.yawords-links li a', jC).unbind();
        jLinks.filter('.yawords-active').prependTo($('.yawords-links', jC));
        jLinks.not('.yawords-active').toggle();
        jLinks.click(function(){
            var jMe = $(this);
            if(jMe.hasClass('yawords-active')){
                jLinks.not('.yawords-active').toggle();
            } else {
                yawords.setActive(jMe.attr('id').replace('yawords-', ''));
                jMe.prependTo($('.yawords-links', jC));
                jLinks.filter('.yawords-active').add(jMe).toggleClass('yawords-active');
                jLinks.not('.yawords-active').hide();
            }
            return false;
        });
        update();
        refresh();
    });

})(jQuery, window.Slovari, window.Lego);

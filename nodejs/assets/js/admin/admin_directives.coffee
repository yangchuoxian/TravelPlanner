app = angular.module 'vtDirectives', []
# auto focus on text input area
app.directive 'autoFocus', ->
    scope:
        trigger: '=autoFocus'
    link: (scope, element) ->
        scope.$watch 'trigger', (value) ->
            if  value == true then element[0].focus()
# scroll to top button
app.directive 'scrollToTop', ['$location', '$anchorScroll', ($location, $anchorScroll) ->
    restrict: 'A'
    link: (scope, element, attr) ->
        element.on 'click', () ->
            $location.hash 'title'
            $anchorScroll()
]
# directive to make the hint message fade out after 1 second
app.directive 'hintMessage', ['$timeout', ($timeout) ->
    scope:
        messageContent: '=messageContent'
    restrict: 'A'
    link: (scope, element, attr)  ->
        $timeout () ->
            scope.messageContent = null
        , 1000
]
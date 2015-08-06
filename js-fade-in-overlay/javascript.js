( function() {

  var $ = window.jQuery

  $( document ).ready( function() {

    var $openButton = $( '.open-survey-button' )
    var $closeButton = $( '.close-survey-button' )

    var overlay = document.getElementById( 'surveygizmo-overlay' )

    $openButton.on( 'click', function( $event ) {

      // Open Survey Popup
      overlay.className = ''
      setTimeout(
        function() {
          overlay.className = 'opaque-visible'
        },
        // NOTE: 1 millisecond pause ensures that element is shown before opacity transition can start
        1
      )
    })

    $closeButton.on( 'click', function( $event ) {

      // Close Survey Popup
      overlay.className = ''
      setTimeout(
        function() {
          overlay.className = 'hide'
        },
        1000
      )
    })
  })
})()


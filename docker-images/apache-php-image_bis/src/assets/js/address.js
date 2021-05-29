$(function() {
    
    function loadAddress() {
        $.getJSON( "/api/address/", function( address ) {
            var message = address[0].adress + " " + address[0].city + " " + address[0].country;
            $(".hereToModify").text(message);
        });    
    };
    
    loadAddress();
    setInterval( loadAddress, 2000 );

});

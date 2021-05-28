var Chance = require('chance');
var chance = new Chance();

var express = require('express');
var app = express();

app.get('/', function(req, res) {
    res.send( generateAddr() );
});

app.listen(3000, function() {
    console.log("Accepte des requête HTTP sur le port 3000");
});

function generateAddr() {
    var numberOfAdresse = chance.integer({
        min: 1,
        max: 10
    });
    console.log(numberOfAdresse);

    var adresses = [];
    
    for (var i = 0; i < numberOfAdresse; ++i) {

        adresses.push({
            adress: chance.address(),
            city: chance.city(),
            country: chance.country()       
        });
    };
    console.log(adresses);
    return adresses;
}


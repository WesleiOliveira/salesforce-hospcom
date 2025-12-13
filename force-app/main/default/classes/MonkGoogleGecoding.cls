@isTest
global class MonkGoogleGecoding implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();        
        res.setStatusCode(200);
        res.setBody('{"results": [ {"address_components": [{"long_name": "717","short_name": "717","types": [ "street_number"]},{"long_name": "Rua 89","short_name": "R. 89","types": ["route"] },{"long_name": "Setor Sul","short_name": "St. Sul","types": ["political","sublocality","sublocality_level_1" ]},{"long_name": "Goiânia","short_name": "Goiânia", "types": [ "administrative_area_level_2", "political"]},{"long_name": "Goiás", "short_name": "GO", "types": ["administrative_area_level_1", "political"] }, {"long_name": "Brazil", "short_name": "BR", "types": ["country","political" ]},{"long_name": "74093-140","short_name": "74093-140", "types": [ "postal_code"] } ], "formatted_address": "R. 89, 717 - St. Sul, Goiânia - GO, 74093-140, Brazil","geometry": {"bounds": { "northeast": {"lat": -16.6955034,"lng": -49.2579055}, "southwest": {"lat": -16.6957764, "lng": -49.2582093 }}, "location": { "lat": -16.6956286,"lng": -49.2580608 }, "location_type": "ROOFTOP", "viewport": { "northeast": {"lat": -16.6942800697085,"lng": -49.25672221970851 },"southwest": {"lat": -16.6969780302915,"lng": -49.2594201802915 }  }  }, "place_id": "ChIJw5DxcBPxXpMRE5kVjP4WZMc", "types": [ "premise"]}],"status": "OK"}');
           return res;
    }
}
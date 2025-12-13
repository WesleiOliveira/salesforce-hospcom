({   
    getUserInfo: function(cmp) {
    var query = "SELECT Id, Name, Email FROM User WHERE Id = '" + $A.get("$SObjectType.CurrentUser.Id") + "'";
    return this.soql(cmp, query)
        .then(function(users) {
            if (users && users.length > 0) {
                return users[0];
            }
            throw new Error("User not found");
        })
        .catch(function(error) {
            console.error("Error fetching user info:", error);
            throw error;
        });
	},
    sendUserInfoToIframe: function(cmp, userInfo) {
        var iframe = cmp.find("iframeElement").getElement();
        console.log('>>>>>>> iframe:  ', iframe);
    
        var sendMessage = function() {
            console.log('>>>>>>>sendMessage : iframe.contentWindow == ', iframe.contentWindow);
    
            if (iframe.contentWindow) {
                iframe.contentWindow.postMessage(JSON.stringify(userInfo), "https://iagov.hospcom.net");
            }
        };
    
        if (iframe.contentWindow) {
            sendMessage();
        } else {
            console.log('>>>>>>> wait for iframe to load ... ');
            iframe.addEventListener('load', sendMessage);
        }
    },
})
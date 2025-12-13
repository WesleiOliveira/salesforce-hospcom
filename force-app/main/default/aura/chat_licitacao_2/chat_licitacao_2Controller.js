({
    doInit: function(component, event, helper) {
        console.log('>>>>>>> running doInit');
        helper.getUserInfo(component)
        .then(function(userInfo) {
            component.set("v.userInfo", userInfo);
            var salesforce_auth_token = "13b876e2-5638-4e37-abee-be6d5c75d238";
            var data = {
                "salesforce_auth_token": salesforce_auth_token,
                "userInfo": userInfo,
            }
            console.log('>>>>>>> doInit - helper.getUserInfo.then ... ');
            helper.sendUserInfoToIframe(component, data);
        });
    }
})
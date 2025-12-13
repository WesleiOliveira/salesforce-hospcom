({  
    // Load current profile picture
    onInit: function(component) {
        var action = component.get("c.getProfilePicture"); 
        action.setParams({
            parentId: component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var attachment = a.getReturnValue();
            console.log(attachment);
            if (attachment && attachment.Id) {
                component.set('v.pictureSrc', 'https://hospcomhospitalar.force.com/Sales/servlet/servlet.FileDownload?file='
                                                  + attachment.Id);
            }
        });
        $A.enqueueAction(action); 
    },
     
    onDragOver: function(component, event) {
        event.preventDefault();
    },
 
    onDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("Você pode enviar apenas uma foto.");
        }
        helper.readFile(component, helper, files[0]);
    }
     
})
({
  doInit: function(cmp, event, helper) {
    cmp.set("v.task", {
      subject: "",
      activityDate: "",
      id: ""
    });

    console.log("doInit() iniciado");
    helper.helperMethod(cmp, event, helper);
  },
  handleTaskClick: function(cmp, event, helper) {
    var taskId = cmp.get("v.taskId")

    console.log("Task clicada:", taskId);
    var url = "https://hospcom.my.site.com/Sales/s/task/" + taskId;
    window.open(url, "_blank");
  }
});
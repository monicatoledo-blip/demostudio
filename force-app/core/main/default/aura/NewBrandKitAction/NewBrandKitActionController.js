({
    doInit: function (component) {
        var flow = component.find("flow");
        flow.startFlow("New_Brand_Kit");
    },
    handleStatus: function (component, event) {
        var status = event.getParam("status");
        if (status === "FINISHED" || status === "FINISHED_SCREEN") {
            $A.get("e.force:navigateToObjectHome").fire({ scope: "Demo_Theme__c" });
        }
    }
})

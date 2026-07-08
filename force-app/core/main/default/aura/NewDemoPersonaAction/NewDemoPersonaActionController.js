({
    doInit: function (component) {
        var flow = component.find("flow");
        flow.startFlow("New_Demo_Persona");
    },
    handleStatus: function (component, event) {
        var status = event.getParam("status");
        if (status !== "FINISHED" && status !== "FINISHED_SCREEN") return;
        // The flow's Create_Persona element (storeOutputAutomatically=true)
        // exposes an SObject variable whose .Id is the new record.
        var outputs = event.getParam("outputVariables") || [];
        var newId = null;
        for (var i = 0; i < outputs.length; i++) {
            var v = outputs[i];
            if (!v) continue;
            if (v.value && typeof v.value === "object" && v.value.Id) {
                newId = v.value.Id;
                break;
            }
            if (typeof v.value === "string" && (v.value.length === 15 || v.value.length === 18)) {
                newId = v.value;
                break;
            }
        }
        if (newId) {
            $A.get("e.force:navigateToSObject").fire({ recordId: newId });
        } else {
            $A.get("e.force:navigateToObjectHome").fire({ scope: "Demo_Persona__c" });
        }
    }
})

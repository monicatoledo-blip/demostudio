import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deployStory from '@salesforce/apex/DemoStudioDeployService.deployStory';
import teardownStory from '@salesforce/apex/DemoStudioDeployService.teardownStory';
import STATUS_FIELD from '@salesforce/schema/Demo_Story__c.Status__c';
import DEPLOYED_FIELD from '@salesforce/schema/Demo_Story__c.Last_Deployed__c';

export default class DemoStoryDeploy extends LightningElement {
    @api recordId;
    loading = false;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD, DEPLOYED_FIELD] })
    story;

    get status() {
        return (this.story && this.story.data && getFieldValue(this.story.data, STATUS_FIELD)) || 'Draft';
    }
    get lastDeployed() {
        return this.story && this.story.data ? getFieldValue(this.story.data, DEPLOYED_FIELD) : null;
    }
    get statusVariant() {
        if (this.status === 'Deployed') return 'success';
        if (this.status === 'Error') return 'error';
        return 'inverse';
    }

    handleDeploy() {
        this.run(deployStory, 'Deployed to the org');
    }
    handleTeardown() {
        this.run(teardownStory, 'Torn down');
    }

    async run(apexFn, successVerb) {
        this.loading = true;
        try {
            await apexFn({ storyId: this.recordId });
            this.toast('Success', successVerb + '.', 'success');
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        } catch (e) {
            const msg = (e && e.body && e.body.message) || (e && e.message) || 'Unknown error';
            this.toast('Something went wrong', msg, 'error');
        } finally {
            this.loading = false;
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}

import { LightningElement, api } from 'lwc';

const ICON_BY_TYPE = {
    Email: { name: 'utility:email', bg: '#1e88e5' },
    SMS: { name: 'utility:sms', bg: '#00b389' },
    Web: { name: 'utility:world', bg: '#f57c00' },
    Doc: { name: 'utility:upload', bg: '#7c4dff' },
    Call: { name: 'utility:call', bg: '#00838f' },
    Meeting: { name: 'utility:event', bg: '#5c6bc0' }
};

export default class DemoActivityTimeline extends LightningElement {
    @api activities;

    get hasActivities() {
        return this.activities && this.activities.length > 0;
    }

    get decoratedActivities() {
        return (this.activities || []).map((a) => {
            const icon = ICON_BY_TYPE[a.Type__c] || { name: a.Icon__c || 'utility:activity', bg: '#5c6bc0' };
            return {
                ...a,
                iconName: icon.name,
                iconStyle: `background:${icon.bg};`
            };
        });
    }
}

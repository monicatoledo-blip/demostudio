import { LightningElement, api } from 'lwc';

const STYLE_CLASS = {
    'Info':    'alert-cat alert-cat--info',
    'Success': 'alert-cat alert-cat--success',
    'Warning': 'alert-cat alert-cat--warning',
    'Danger':  'alert-cat alert-cat--danger'
};

export default class DemoAiInsightsAlerts extends LightningElement {
    @api alerts;

    get decoratedAlerts() {
        return (this.alerts || []).map((a, i) => ({
            ...a,
            _key: a.Id || `alert-${i}`,
            _catClass: STYLE_CLASS[a.Category_Style__c] || STYLE_CLASS.Info
        }));
    }

    get hasAlerts() {
        return this.decoratedAlerts.length > 0;
    }
}

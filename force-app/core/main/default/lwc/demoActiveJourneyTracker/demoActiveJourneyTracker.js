import { LightningElement, api } from 'lwc';

const STATUS_STYLE = {
    Active:    { color: '#00b389', label: 'Active' },
    Paused:    { color: '#f57c00', label: 'Paused' },
    Completed: { color: '#607d8b', label: 'Completed' },
    Exited:    { color: '#e53935', label: 'Exited' }
};

const BU_ACCENT = {
    Commercial:      '#0176d3',
    Wealth:          '#7c4dff',
    Retail:          '#00b389',
    'Corporate Comms': '#f57c00',
    Treasury:        '#5c6bc0'
};

export default class DemoActiveJourneyTracker extends LightningElement {
    @api journeys;

    get hasJourneys() {
        return this.journeys && this.journeys.length > 0;
    }

    get decoratedJourneys() {
        return (this.journeys || []).map((j) => {
            const s = STATUS_STYLE[j.Status__c] || STATUS_STYLE.Active;
            const bu = BU_ACCENT[j.Business_Unit__c] || '#0176d3';
            return {
                ...j,
                statusStyle: `--status-color:${s.color};`,
                buStyle: `background:${bu};`
            };
        });
    }
}

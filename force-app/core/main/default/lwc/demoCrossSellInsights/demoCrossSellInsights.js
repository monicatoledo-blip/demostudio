import { LightningElement, api } from 'lwc';

export default class DemoCrossSellInsights extends LightningElement {
    @api insights;

    get hasInsights() {
        return this.insights && this.insights.length > 0;
    }
}

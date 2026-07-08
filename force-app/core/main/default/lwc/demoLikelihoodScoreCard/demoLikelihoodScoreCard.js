import { LightningElement, api } from 'lwc';

export default class DemoLikelihoodScoreCard extends LightningElement {
    @api persona;

    get openPct() { return this.persona && this.persona.Open_Likelihood__c || 0; }
    get clickPct() { return this.persona && this.persona.Click_Likelihood__c || 0; }
    get unsubPct() { return this.persona && this.persona.Unsubscribe_Risk__c || 0; }

    get openStyle() { return `--fill:${this.openPct}%; --bar-color:#00b389;`; }
    get clickStyle() { return `--fill:${this.clickPct}%; --bar-color:#1e88e5;`; }
    get unsubStyle() { return `--fill:${this.unsubPct}%; --bar-color:#e53935;`; }

    get openLabel() { return `${this.openPct}%`; }
    get clickLabel() { return `${this.clickPct}%`; }
    get unsubLabel() { return `${this.unsubPct}%`; }
}

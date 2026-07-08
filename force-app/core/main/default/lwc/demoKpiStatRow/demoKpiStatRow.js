import { LightningElement, api } from 'lwc';

export default class DemoKpiStatRow extends LightningElement {
    @api kpis;

    get decoratedKpis() {
        return (this.kpis || []).map((k, i) => ({
            ...k,
            _key: k.Id || `kpi-${i}`,
            _tileClass: k.Is_Highlighted__c
                ? 'kpi-tile kpi-tile--highlight'
                : 'kpi-tile',
            _valueClass: k.Is_Highlighted__c
                ? 'kpi-value kpi-value--highlight'
                : 'kpi-value'
        }));
    }

    get hasKpis() {
        return this.decoratedKpis.length > 0;
    }
}

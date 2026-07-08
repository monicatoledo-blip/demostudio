import { LightningElement, api } from 'lwc';

export default class DcSegmentCanvasContainer extends LightningElement {
    @api container;

    get title() { return this.container?.include ? 'Include when...' : 'Exclude when...'; }
    get variant() { return this.container?.include ? 'include' : 'exclude'; }
    get containerKey() { return this.container?.containerKey; }
    get rows() { return this.container?.rows || []; }
    get isEmpty() { return this.rows.length === 0; }
    get containerClass() { return `container container--${this.variant}`; }
    get operatorOptions() { return this.container?.operatorOptions || []; }
    get operator() { return this.container?.operator; }

    handleOperator(e) {
        this.dispatchEvent(new CustomEvent('operator', {
            detail: { value: e.detail.value, container: this.containerKey }
        }));
    }
    handleRowOp(e) { this.emitRow('rowop', e); }
    handleRowValue(e) { this.emitRow('rowvalue', e); }
    handleRowValueEnd(e) { this.emitRow('rowvalueend', e); }
    handleRowRemove(e) { this.emitRow('rowremove', e); }

    emitRow(name, e) {
        this.dispatchEvent(new CustomEvent(name, {
            detail: { ...e.detail, rowId: e.detail.rowId, container: this.containerKey }
        }));
    }
}

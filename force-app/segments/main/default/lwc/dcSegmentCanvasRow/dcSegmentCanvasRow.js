import { LightningElement, api } from 'lwc';

export default class DcSegmentCanvasRow extends LightningElement {
    @api row;
    @api containerKey;

    get rowId() { return this.row?.id; }
    get label() { return this.row?.label; }
    get operatorOptions() { return this.row?.operatorOptions || []; }
    get op() { return this.row?.op; }
    get needsValue() { return this.row?.needsValue; }
    get isBetween() { return this.row?.isBetween; }
    get isInList() { return this.row?.isInList; }
    get isPicklist() { return this.row?.isPicklist; }
    get needsScalarInput() { return this.needsValue && !this.isBetween && !this.isInList && !this.isPicklist; }
    get inputType() { return this.row?.inputType; }
    get picklistOptions() { return this.row?.picklistOptions || []; }
    get value() { return this.row?.value; }
    get valueEnd() { return this.row?.valueEnd; }
    get listValueString() { return this.row?.listValueString; }

    emit(name, extra) {
        this.dispatchEvent(new CustomEvent(name, {
            detail: { rowId: this.rowId, container: this.containerKey, ...extra }
        }));
    }
    handleOp(e) { this.emit('rowop', { value: e.detail.value }); }
    handleValue(e) { this.emit('rowvalue', { value: e.detail?.value ?? e.target.value }); }
    handleValueEnd(e) { this.emit('rowvalueend', { value: e.detail?.value ?? e.target.value }); }
    handleRemove() { this.emit('rowremove', {}); }
}

import { LightningElement, api, track } from 'lwc';

const OPS_BY_TYPE = {
    STRING:   [{value:'eq',label:'equals'},{value:'ne',label:'not equal'},{value:'contains',label:'contains'},{value:'startsWith',label:'starts with'},{value:'in',label:'in list'},{value:'isNull',label:'is empty'},{value:'isNotNull',label:'is not empty'}],
    EMAIL:    [{value:'eq',label:'equals'},{value:'ne',label:'not equal'},{value:'contains',label:'contains'},{value:'isNull',label:'is empty'},{value:'isNotNull',label:'is not empty'}],
    PHONE:    [{value:'eq',label:'equals'},{value:'contains',label:'contains'},{value:'isNull',label:'is empty'},{value:'isNotNull',label:'is not empty'}],
    PICKLIST: [{value:'eq',label:'equals'},{value:'ne',label:'not equal'},{value:'in',label:'in list'},{value:'notIn',label:'not in list'},{value:'isNull',label:'is empty'},{value:'isNotNull',label:'is not empty'}],
    MULTIPICKLIST:[{value:'contains',label:'includes'},{value:'isNull',label:'is empty'}],
    BOOLEAN:  [{value:'eq',label:'equals'}],
    CURRENCY: [{value:'eq',label:'='},{value:'gt',label:'>'},{value:'gte',label:'>='},{value:'lt',label:'<'},{value:'lte',label:'<='},{value:'between',label:'between'},{value:'isNull',label:'is empty'}],
    DOUBLE:   [{value:'eq',label:'='},{value:'gt',label:'>'},{value:'gte',label:'>='},{value:'lt',label:'<'},{value:'lte',label:'<='},{value:'between',label:'between'},{value:'isNull',label:'is empty'}],
    INTEGER:  [{value:'eq',label:'='},{value:'gt',label:'>'},{value:'gte',label:'>='},{value:'lt',label:'<'},{value:'lte',label:'<='},{value:'between',label:'between'},{value:'isNull',label:'is empty'}],
    PERCENT:  [{value:'eq',label:'='},{value:'gt',label:'>'},{value:'lt',label:'<'},{value:'between',label:'between'}],
    DATE:     [{value:'eq',label:'on'},{value:'gt',label:'after'},{value:'lt',label:'before'},{value:'between',label:'between'},{value:'isNull',label:'is empty'}],
    DATETIME: [{value:'gt',label:'after'},{value:'lt',label:'before'},{value:'between',label:'between'}],
    DEFAULT:  [{value:'eq',label:'equals'},{value:'isNull',label:'is empty'},{value:'isNotNull',label:'is not empty'}]
};

function inputTypeFor(t) {
    switch (t) {
        case 'CURRENCY': case 'DOUBLE': case 'INTEGER': case 'PERCENT': return 'number';
        case 'DATE': return 'date';
        case 'DATETIME': return 'datetime';
        case 'EMAIL': return 'email';
        case 'PHONE': return 'tel';
        default: return 'text';
    }
}

function newContainer(include) {
    return { id: `c-${Date.now()}-${Math.random().toString(36).slice(2,6)}`,
             kind: 'container', operator: 'AND', include, children: [] };
}

function newDirect(objectApi, attr) {
    const ops = OPS_BY_TYPE[attr.type] || OPS_BY_TYPE.DEFAULT;
    return { id: `r-${Date.now()}-${Math.random().toString(36).slice(2,6)}`,
             kind: 'direct', object: objectApi, field: attr.apiName,
             label: attr.label, fieldType: attr.type,
             picklistValues: attr.picklistValues || [],
             op: ops[0].value, value: null, valueEnd: null };
}

export default class DcSegmentCanvas extends LightningElement {
    @track _include = newContainer(true);
    @track _exclude = newContainer(false);

    @api get filterTree() {
        return { kind:'container', operator:'AND', include:true,
                 children: [ this.serialize(this._include),
                             ...(this._exclude.children.length ? [this.serialize(this._exclude)] : []) ] };
    }
    set filterTree(v) {
        if (!v || !v.children) return;
        const inc = v.children.find(c => c.include !== false);
        const exc = v.children.find(c => c.include === false);
        if (inc) this._include = this.hydrate(inc, true);
        if (exc) this._exclude = this.hydrate(exc, false);
    }

    @api addAttribute(objectApi, attr) {
        const row = newDirect(objectApi, attr);
        this._include = { ...this._include, children: [...this._include.children, row] };
        this.emitChange();
    }

    get includeView() { return this.viewFor(this._include, 'include'); }
    get excludeView() { return this.viewFor(this._exclude, 'exclude'); }

    viewFor(container, key) {
        return {
            ...container,
            containerKey: key,
            operatorOptions: [{label:'AND',value:'AND'},{label:'OR',value:'OR'}],
            rows: container.children.map(r => this.viewRow(r))
        };
    }

    viewRow(r) {
        const ops = OPS_BY_TYPE[r.fieldType] || OPS_BY_TYPE.DEFAULT;
        const needsValue = !(r.op === 'isNull' || r.op === 'isNotNull');
        const isBetween = r.op === 'between';
        const isInList = r.op === 'in' || r.op === 'notIn';
        const isPicklist = r.fieldType === 'PICKLIST' && !isInList;
        return {
            ...r,
            operatorOptions: ops,
            inputType: inputTypeFor(r.fieldType),
            needsValue,
            isBetween,
            isInList,
            isPicklist,
            picklistOptions: (r.picklistValues || []).map(p => ({label:p.label, value:p.value})),
            listValueString: Array.isArray(r.value) ? r.value.join(', ') : (r.value || '')
        };
    }

    handleContainerOperator(e) {
        const key = e.currentTarget.dataset.container;
        const target = key === 'include' ? '_include' : '_exclude';
        this[target] = { ...this[target], operator: e.detail.value };
        this.emitChange();
    }

    handleRowOp(e) {
        const rowId = e.currentTarget.dataset.rowId;
        const containerKey = e.currentTarget.dataset.container;
        this.mutateRow(containerKey, rowId, r => ({ ...r, op: e.detail.value, value: null, valueEnd: null }));
    }
    handleRowValue(e) {
        const rowId = e.currentTarget.dataset.rowId;
        const containerKey = e.currentTarget.dataset.container;
        const raw = e.detail?.value ?? e.target.value;
        this.mutateRow(containerKey, rowId, r => {
            if (r.op === 'in' || r.op === 'notIn') {
                return { ...r, value: String(raw).split(',').map(s => s.trim()).filter(Boolean) };
            }
            return { ...r, value: raw };
        });
    }
    handleRowValueEnd(e) {
        const rowId = e.currentTarget.dataset.rowId;
        const containerKey = e.currentTarget.dataset.container;
        const raw = e.detail?.value ?? e.target.value;
        this.mutateRow(containerKey, rowId, r => ({ ...r, valueEnd: raw }));
    }
    handleRowRemove(e) {
        const rowId = e.currentTarget.dataset.rowId;
        const containerKey = e.currentTarget.dataset.container;
        const target = containerKey === 'include' ? '_include' : '_exclude';
        this[target] = { ...this[target], children: this[target].children.filter(c => c.id !== rowId) };
        this.emitChange();
    }

    mutateRow(containerKey, rowId, mutator) {
        const target = containerKey === 'include' ? '_include' : '_exclude';
        this[target] = {
            ...this[target],
            children: this[target].children.map(c => c.id === rowId ? mutator(c) : c)
        };
        this.emitChange();
    }

    emitChange() {
        this.dispatchEvent(new CustomEvent('filterchange', { detail: this.filterTree }));
    }

    serialize(container) {
        return {
            kind: 'container', operator: container.operator, include: container.include,
            children: container.children.map(r => this.serializeRow(r))
        };
    }
    serializeRow(r) {
        if (r.kind === 'container') return this.serialize(r);
        return { kind: 'direct', field: r.field, op: r.op, value: r.value, valueEnd: r.valueEnd };
    }
    hydrate(container, include) {
        return { id: `c-${Date.now()}-${Math.random().toString(36).slice(2,6)}`,
                 kind: 'container', operator: container.operator || 'AND', include,
                 children: (container.children || []).map(c => this.hydrateRow(c)) };
    }
    hydrateRow(r) {
        if (r.kind === 'container') return this.hydrate(r, r.include !== false);
        return { id: `r-${Date.now()}-${Math.random().toString(36).slice(2,6)}`,
                 kind: 'direct', field: r.field, label: r.field, fieldType: 'STRING',
                 picklistValues: [], op: r.op, value: r.value, valueEnd: r.valueEnd,
                 object: 'Demo_DMO_Individual__c' };
    }
}

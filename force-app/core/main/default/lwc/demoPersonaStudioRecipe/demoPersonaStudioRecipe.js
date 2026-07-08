import { LightningElement, api } from 'lwc';

const COMPONENT_CATALOG = [
    { name: 'demoUnifiedProfileHeader', label: 'Unified Profile Card', description: 'Hero card with Unified Card / Individuals tabs, avatar, metrics, engagement ring.', defaultSlot: 'leftRail' },
    { name: 'demoKpiStatRow',           label: 'KPI Stat Row',         description: 'Wide stat tiles (Assets / Liabilities / Net Worth / etc.) with optional highlighted tile.', defaultSlot: 'center' },
    { name: 'demoAiInsightsAlerts',     label: 'AI Alerts',            description: 'Scannable list of Data Cloud flags (Retirement Gap, Cash Optimization, Debt Alert). Distinct from Cross-Sell Insights (which pitches product bundles).', defaultSlot: 'center' },
    { name: 'demoAgentforceBrief',      label: 'Agentforce Brief',      description: 'Intent Summary, Key Context, Suggested Opener with CTAs.', defaultSlot: 'center' },
    { name: 'demoCrossSellInsights',    label: 'Cross-Sell Insights',   description: 'AI-recommendation cards with "why this suggestion" reasoning.', defaultSlot: 'center' },
    { name: 'demoNextBestActions',      label: 'Next Best Actions',     description: 'Card grid of top plays with editable hero images (auto-falls back if URL blocked).', defaultSlot: 'center' },
    { name: 'demoActivityTimeline',     label: 'Activity Timeline',     description: 'Vertical timeline of engagement events.', defaultSlot: 'rightRail' },
    { name: 'demoLikelihoodScoreCard',  label: 'Likelihood Score Card', description: 'Open / Click / Unsubscribe likelihood bars.', defaultSlot: 'rightRail' },
    { name: 'demoActiveJourneyTracker', label: 'Active Journey Tracker', description: 'BU-colored journey status cards.', defaultSlot: 'rightRail' }
];

const SLOTS = [
    { key: 'leftRail',  label: 'Left Rail' },
    { key: 'center',    label: 'Center' },
    { key: 'rightRail', label: 'Right Rail' }
];

const CATALOG_BY_NAME = COMPONENT_CATALOG.reduce((acc, c) => {
    acc[c.name] = c;
    return acc;
}, {});

export default class DemoPersonaStudioRecipe extends LightningElement {
    @api persona;

    isCollapsed = false;

    get showSelector() { return !this.isCollapsed; }
    get showCollapsedHint() { return this.isCollapsed; }
    get collapseIcon() { return this.isCollapsed ? 'utility:chevronright' : 'utility:chevronleft'; }
    get collapseAltText() { return this.isCollapsed ? 'Expand component picker' : 'Collapse component picker'; }

    handleCollapseToggle() {
        this.isCollapsed = !this.isCollapsed;
        this.dispatchEvent(new CustomEvent('collapse', {
            detail: { collapsed: this.isCollapsed }
        }));
    }

    get recipe() {
        try {
            return JSON.parse(this.persona.Component_Recipe__c || '{}');
        } catch (e) {
            return {};
        }
    }

    // Names of every component currently placed in any slot.
    get placedNames() {
        const r = this.recipe;
        const names = new Set();
        for (const slot of SLOTS) {
            for (const c of (r[slot.key] || [])) {
                if (c && c.component) names.add(c.component);
            }
        }
        return names;
    }

    get slots() {
        const r = this.recipe;
        return SLOTS.map((slot) => {
            const list = r[slot.key] || [];
            const placedItems = list.map((entry, idx) => {
                const meta = CATALOG_BY_NAME[entry.component] || { label: entry.component, description: '' };
                return {
                    slot: slot.key,
                    name: entry.component,
                    // Slot-qualified so LWC diffs items in place across
                    // adds/removes/reorders and the same component moving
                    // between slots doesn't collide with a stale key.
                    _key: `${slot.key}__${entry.component}`,
                    label: meta.label,
                    description: meta.description,
                    position: idx + 1
                };
            });
            return {
                ...slot,
                placedItems,
                hasPlacedItems: placedItems.length > 0
            };
        });
    }

    // The "available components" tray shows every catalog entry not yet
    // placed anywhere. Each row has an "Add to Left/Center/Right" trio.
    get availableComponents() {
        const placed = this.placedNames;
        return COMPONENT_CATALOG
            .filter((c) => !placed.has(c.name))
            .map((c) => ({
                ...c,
                addLeft: `leftRail__${c.name}`,
                addCenter: `center__${c.name}`,
                addRight: `rightRail__${c.name}`
            }));
    }

    get hasAvailableComponents() {
        return this.availableComponents.length > 0;
    }

    _emit(recipe) {
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                field: 'Component_Recipe__c',
                value: JSON.stringify(recipe)
            }
        }));
    }

    _stripFromAll(recipe, componentName) {
        for (const slot of SLOTS) {
            recipe[slot.key] = (recipe[slot.key] || []).filter((c) => c.component !== componentName);
        }
    }

    handleAdd(e) {
        const [slotKey, componentName] = e.currentTarget.dataset.target.split('__');
        const r = { ...this.recipe };
        this._stripFromAll(r, componentName);
        r[slotKey] = [...(r[slotKey] || []), { component: componentName }];
        this._emit(r);
    }

    handleRemove(e) {
        const { slot, name } = e.currentTarget.dataset;
        const r = { ...this.recipe };
        r[slot] = (r[slot] || []).filter((c) => c.component !== name);
        this._emit(r);
    }

    // ---- Drag & drop reorder ----
    // Tracks the item picked up. Cleared on dragend regardless of drop success
    // so a cancelled drag doesn't leak state into the next attempt.
    _drag = null;

    handleDragStart(e) {
        const { slot, name } = e.currentTarget.dataset;
        this._drag = { slot, name };
        e.dataTransfer.effectAllowed = 'move';
        // Firefox needs data set on the transfer or the drag is silently aborted.
        try { e.dataTransfer.setData('text/plain', name); } catch (_) { /* IE fallback */ }
        e.currentTarget.classList.add('is-dragging');
    }

    handleDragEnd(e) {
        e.currentTarget.classList.remove('is-dragging');
        // Clear any lingering hover indicators on siblings if the drop landed
        // outside a valid target.
        const hovers = this.template.querySelectorAll('.drag-over, .drag-over-slot');
        hovers.forEach((el) => el.classList.remove('drag-over', 'drag-over-slot'));
        this._drag = null;
    }

    handleDragOverItem(e) {
        if (!this._drag) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        e.currentTarget.classList.add('drag-over');
    }

    handleDragLeaveItem(e) {
        e.currentTarget.classList.remove('drag-over');
    }

    handleDropOnItem(e) {
        if (!this._drag) return;
        e.preventDefault();
        e.stopPropagation();
        e.currentTarget.classList.remove('drag-over');
        const { slot: targetSlot, name: targetName } = e.currentTarget.dataset;
        this._reorder(this._drag.slot, this._drag.name, targetSlot, targetName);
    }

    // Dropping directly on a slot container (not on a specific item) appends
    // to that slot — makes empty slots and end-of-list drops discoverable.
    handleDragOverSlot(e) {
        if (!this._drag) return;
        e.preventDefault();
        e.dataTransfer.dropEffect = 'move';
        e.currentTarget.classList.add('drag-over-slot');
    }

    handleDragLeaveSlot(e) {
        e.currentTarget.classList.remove('drag-over-slot');
    }

    handleDropOnSlot(e) {
        if (!this._drag) return;
        e.preventDefault();
        e.currentTarget.classList.remove('drag-over-slot');
        const targetSlot = e.currentTarget.dataset.slot;
        this._reorder(this._drag.slot, this._drag.name, targetSlot, null);
    }

    _reorder(fromSlot, fromName, toSlot, toName) {
        if (fromSlot === toSlot && fromName === toName) return;
        const r = { ...this.recipe };
        // Snapshot the moving entry and strip it from its source slot.
        const src = [...(r[fromSlot] || [])];
        const srcIdx = src.findIndex((c) => c.component === fromName);
        if (srcIdx < 0) return;
        const [item] = src.splice(srcIdx, 1);
        r[fromSlot] = src;
        // Insert into the target slot. If we know the target item, place
        // immediately before it; otherwise append.
        const dst = [...(r[toSlot] || [])];
        if (toName) {
            const dstIdx = dst.findIndex((c) => c.component === toName);
            if (dstIdx < 0) {
                dst.push(item);
            } else {
                dst.splice(dstIdx, 0, item);
            }
        } else {
            dst.push(item);
        }
        r[toSlot] = dst;
        this._emit(r);
    }
}

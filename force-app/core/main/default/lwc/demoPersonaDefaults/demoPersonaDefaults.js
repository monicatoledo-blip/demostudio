// Shared "default persona" values used by both the Studio preview and the
// real Contact record page shell. Guarantees a shipped persona always shows
// meaningful content — never a page full of blank widgets.

import { LightningElement } from 'lwc';
export default class DemoPersonaDefaults extends LightningElement {}

export const PLACEHOLDER_PERSONA = {
    Brand__c: 'Cumulus Bank',
    First_Name__c: 'Rachel',
    Last_Name__c: 'Adams',
    Title__c: 'VP of Finance',
    Company__c: 'BrightPath Logistics',
    Customer_ID__c: 'C-100482',
    Badge_Text__c: 'Pre-Approved Buyer',
    Primary_Email__c: 'rachel.adams@example.com',
    Primary_Phone__c: '(315) 555-1254',
    Primary_Address__c: '2259 Green Avenue, Alpharetta, GA 30004',
    Segment__c: 'Small Business Cross-Sell',
    Lifecycle_Stage__c: 'Cross-Sell Target',
    LTV__c: 11450,
    Propensity__c: 'High',
    Engagement_Score__c: 84,
    Engagement_Label__c: 'Highly Engaged',
    Risk_Tier__c: 'Medium',
    Intent_Summary__c: 'Rachel submitted a small business loan application at Cumulus Bank this morning and successfully uploaded her tax returns. She is actively engaging with the Agentforce virtual assistant regarding approval timelines and is a strong cross-sell target for our merchant services bundle.',
    Key_Context__c: 'Rachel is pre-approved for a $150K line of credit for BrightPath Logistics. Her unified profile synced instantly via Data Cloud, showing she has successfully uploaded her SOC-2 attestation and Proof of Funds. She is waiting on final underwriter clearance.',
    Suggested_Opener__c: 'Hi Rachel, I noticed you just uploaded your tax returns for the line of credit application — congratulations on progressing that quickly. I want to make sure we finalize your approval today so you can activate your business banking package before your Q3 growth cycle.',
    Open_Likelihood__c: 92,
    Click_Likelihood__c: 78,
    Unsubscribe_Risk__c: 4
};

export const PLACEHOLDER_IDENTITIES = [
    { Id: 'ph-e1', Type__c: 'Email', Value__c: 'rachel.adams@example.com', Label__c: 'Work', Sort_Order__c: 1 },
    { Id: 'ph-e2', Type__c: 'Email', Value__c: 'rachel.personal@gmail.com', Label__c: 'Personal', Sort_Order__c: 2 },
    { Id: 'ph-p1', Type__c: 'Phone', Value__c: '(315) 555-1254', Label__c: 'Mobile', Sort_Order__c: 1 },
    { Id: 'ph-a1', Type__c: 'Address', Value__c: '2259 Green Avenue, Alpharetta, GA 30004', Label__c: 'Business', Sort_Order__c: 1 }
];

export const PLACEHOLDER_INSIGHTS = [
    { Id: 'ph-i1', Title__c: 'Merchant Services Bundle', Category__c: 'Cross-Sell', Why_This_Suggestion__c: 'Retail SMBs approved for a line of credit have a 45% attach rate on merchant services when offered within 48 hours of approval.', CTA_Label__c: 'Send Bundle Offer', Sort_Order__c: 1 },
    { Id: 'ph-i2', Title__c: 'Business Credit Card', Category__c: 'Cross-Sell', Why_This_Suggestion__c: 'Cash flow statements show $8K/mo in supplier spend. A business credit card would earn ~$1,900/yr in rebates.', CTA_Label__c: 'Offer Card', Sort_Order__c: 2 }
];

export const PLACEHOLDER_NBAS = [
    { Id: 'ph-n1', Title__c: 'Discuss Loan Approval Path',    Category__c: 'Direct Action', Why_This_Suggestion__c: 'Application uploaded this morning. Fast approval turnaround has a 78% cross-sell attach rate for merchant services within 48 hours.', CTA_Label__c: 'Discuss Options', Image_URL__c: 'https://images.unsplash.com/photo-1556742044-3c52d6e88c62?w=500&h=200&fit=crop', Sort_Order__c: 1 },
    { Id: 'ph-n2', Title__c: 'Optimize Checking Account Funds', Category__c: 'Cash Optimization', Why_This_Suggestion__c: 'Idle balance of $112K exceeds recommended reserve. Move excess to high-yield savings for ~$4.2K annual interest.', CTA_Label__c: 'Present Offer', Image_URL__c: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=500&h=200&fit=crop', Sort_Order__c: 2 }
];

export const PLACEHOLDER_ACTIVITIES = [
    { Id: 'ph-ac1', Type__c: 'Doc', Title__c: 'Uploaded 2023 & 2024 Tax Returns', Description__c: 'Business tax returns uploaded via the small business application portal.', Timestamp_Label__c: 'This morning', Icon__c: 'utility:upload', Sort_Order__c: 1 },
    { Id: 'ph-ac2', Type__c: 'Web', Title__c: 'Checked Application Status', Description__c: 'Visited application status portal 3 times today.', Timestamp_Label__c: 'Today', Icon__c: 'utility:world', Sort_Order__c: 2 }
];

export const PLACEHOLDER_JOURNEYS = [
    { Id: 'ph-j1', Journey_Name__c: 'SMB Application Journey', Business_Unit__c: 'Retail', Status__c: 'Active', Enrolled_Date__c: '2026-06-15' }
];

export const PLACEHOLDER_KPIS = [
    { Id: 'ph-k1', Label__c: 'Assets',      Value__c: '$1,326,969', Sublabel__c: '6 Accounts',             Is_Highlighted__c: false, Sort_Order__c: 1 },
    { Id: 'ph-k2', Label__c: 'Liabilities', Value__c: '$219,180',   Sublabel__c: '5 Accounts',             Is_Highlighted__c: false, Sort_Order__c: 2 },
    { Id: 'ph-k3', Label__c: 'Net Worth',   Value__c: '$1,107,789', Sublabel__c: 'Calculated Insight',     Is_Highlighted__c: true,  Sort_Order__c: 3 },
    { Id: 'ph-k4', Label__c: 'Policies',    Value__c: '$761,876',   Sublabel__c: '2 Active (Coverage)',    Is_Highlighted__c: false, Sort_Order__c: 4 }
];

export const PLACEHOLDER_ALERTS = [
    { Id: 'ph-al1', Category_Label__c: 'Retirement Gap',    Category_Style__c: 'Info',    Title__c: 'Behind Retirement Savings Target', Body__c: 'Current retirement assets $740.9K vs $1.2M target (6x income by age 50).', Sort_Order__c: 1 },
    { Id: 'ph-al2', Category_Label__c: 'Cash Optimization', Category_Style__c: 'Success', Title__c: 'Idle Cash in Checking Account',    Body__c: 'Checking account balance $112.7K exceeds $50.5K (25% of income).',              Sort_Order__c: 2 },
    { Id: 'ph-al3', Category_Label__c: 'Debt Alert',        Category_Style__c: 'Danger',  Title__c: 'High Student Loan Payments',       Body__c: 'Monthly student loan payment $706.82 contributes to a 34.5% DTI ratio.',        Sort_Order__c: 3 }
];

export const PLACEHOLDER_SEGMENTS = [
    { Id: 'ph-s1', Label__c: 'High Spender',          Sort_Order__c: 1 },
    { Id: 'ph-s2', Label__c: 'High Net Worth',        Sort_Order__c: 2 },
    { Id: 'ph-s3', Label__c: 'Under-Insured HNW',     Sort_Order__c: 3 },
    { Id: 'ph-s4', Label__c: 'Household with Children', Sort_Order__c: 4 },
    { Id: 'ph-s5', Label__c: 'Multi-Product Client',  Sort_Order__c: 5 }
];

function isEmpty(v) {
    return v === null || v === undefined || v === '';
}

// Merge placeholder values into a persona ONLY where the real field is empty.
// Real user input always wins. If the persona has no Id yet (studio preview),
// nothing is merged onto the Id field.
export function withPersonaDefaults(realPersona) {
    const merged = { ...PLACEHOLDER_PERSONA };
    if (realPersona) {
        for (const k of Object.keys(realPersona)) {
            if (!isEmpty(realPersona[k])) merged[k] = realPersona[k];
        }
        if (realPersona.Id) merged.Id = realPersona.Id;
    }
    return merged;
}

export function withIdentitiesDefault(real) {
    return real && real.length ? real : PLACEHOLDER_IDENTITIES;
}
export function withInsightsDefault(real) {
    return real && real.length ? real : PLACEHOLDER_INSIGHTS;
}
export function withActivitiesDefault(real) {
    return real && real.length ? real : PLACEHOLDER_ACTIVITIES;
}
export function withJourneysDefault(real) {
    return real && real.length ? real : PLACEHOLDER_JOURNEYS;
}
export function withKpisDefault(real) {
    return real && real.length ? real : PLACEHOLDER_KPIS;
}
export function withAlertsDefault(real) {
    return real && real.length ? real : PLACEHOLDER_ALERTS;
}
export function withSegmentsDefault(real) {
    return real && real.length ? real : PLACEHOLDER_SEGMENTS;
}
export function withNbasDefault(real) {
    return real && real.length ? real : PLACEHOLDER_NBAS;
}

import { LightningElement, api } from 'lwc';

export default class DemoRelatedIdentities extends LightningElement {
    @api identities;

    get emails() {
        return (this.identities || []).filter((i) => i.Type__c === 'Email');
    }
    get phones() {
        return (this.identities || []).filter((i) => i.Type__c === 'Phone');
    }
    get addresses() {
        return (this.identities || []).filter((i) => i.Type__c === 'Address');
    }
    get emailCount() { return this.emails.length; }
    get phoneCount() { return this.phones.length; }
    get addressCount() { return this.addresses.length; }
    get hasEmails() { return this.emailCount > 0; }
    get hasPhones() { return this.phoneCount > 0; }
    get hasAddresses() { return this.addressCount > 0; }
}

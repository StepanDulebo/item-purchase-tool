import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getItems from '@salesforce/apex/ItemController.getItems';
import getFilterOptions from '@salesforce/apex/ItemController.getFilterOptions';
import createPurchase from '@salesforce/apex/PurchaseService.createPurchase';
import getUnsplashImage from '@salesforce/apex/UnsplashService.getImageUrl';
import updateItemImage from '@salesforce/apex/ItemController.updateItemImage';
import Id from '@salesforce/user/Id';

const USER_FIELDS = ['User.IsManager__c'];
const ACCOUNT_FIELDS = ['Account.Name', 'Account.AccountNumber', 'Account.Industry'];

export default class ItemPurchaseTool extends NavigationMixin(LightningElement) {
    @api recordId;
    @track items = [];
    @track filteredItems = [];
    @track cart = [];
    @track typeFilter = '';
    @track familyFilter = '';
    @track searchKey = '';
    @track showCreateModal = false;
    @track typeOptions = [];
    @track familyOptions = [];
    @track selectedItemId;
    @track showCartModal = false;
    @track showDetailsModal = false;
    isManager = false;

    cartColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Price', fieldName: 'Price__c', type: 'currency' },
        { label: 'Quantity', fieldName: 'quantity', type: 'number' }
    ];

    @wire(getRecord, { recordId: Id, fields: USER_FIELDS })
    wiredUser({ data }) {
        if (data) this.isManager = data.fields.IsManager__c.value;
    }

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    account;

    connectedCallback() {
        this.loadFilterOptions();
        this.loadItems();
    }
    get selectedItem() {
    return this.items.find(i => i.Id === this.selectedItemId);
    }


    
    loadFilterOptions() {
        getFilterOptions()
            .then(result => {
                this.typeOptions = this.convertToOptions(result.type || []);
                this.familyOptions = this.convertToOptions(result.family || []);
            })
            .catch(() => {
                this.typeOptions = [{ label: 'All', value: '' }];
                this.familyOptions = [{ label: 'All', value: '' }];
            });
    }

    convertToOptions(values) {
        return values.map(v => ({ label: v || 'All', value: v || '' }));
    }

    handleTypeFilter(event) {
        this.typeFilter = event.detail.value;
        this.loadItems();
    }

    handleFamilyFilter(event) {
        this.familyFilter = event.detail.value;
        this.loadItems();
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.loadItems();
    }

    loadItems() {
        getItems({ typeFilter: this.typeFilter, familyFilter: this.familyFilter, searchKey: this.searchKey })
            .then(result => { this.items = this.filteredItems = result; })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Failed to load items',
                    variant: 'error'
                }));
            });
    }

    
    handleAddToCart(event) {
        const itemId = event.currentTarget.dataset.id;
        const item = this.items.find(i => i.Id === itemId);
        if (!item) return;

        const existing = this.cart.find(i => i.Id === itemId);
        if (existing) existing.quantity += 1;
        else this.cart = [...this.cart, { ...item, quantity: 1 }];

        this.dispatchEvent(new ShowToastEvent({ title: 'Added to Cart', message: item.Name, variant: 'success' }));
    }

    openCartModal() { this.showCartModal = true; }
    closeCartModal() { this.showCartModal = false; }

    handleCheckout() {
        if (!this.cart.length) return;
        createPurchase({ accountId: this.recordId, cartItems: this.cart })
            .then(purchaseId => {
                this.cart = [];
                this.showCartModal = false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: { recordId: purchaseId, objectApiName: 'Purchase__c', actionName: 'view' }
                });
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Checkout Error',
                    message: error.body?.message || 'Checkout failed',
                    variant: 'error'
                }));
            });
    }

   
    handleDetails(event) {
        this.selectedItemId = event.currentTarget.dataset.id;
        this.showDetailsModal = true;
    }

    closeDetailsModal() {
        this.showDetailsModal = false;
        this.selectedItemId = null;
    }





    handleItemCreated(event) {
    const fields = event.detail.fields;
    const itemName = fields.Name || 'item';

    
    const form = this.template.querySelector('lightning-record-edit-form');
    form.submit(fields);

    
    form.addEventListener('success', async (e) => {
        const itemId = e.detail.id;
        try {
            const imageUrl = await getUnsplashImage({ query: itemName });
            if (imageUrl) {
                await updateItemImage({ itemId: itemId, imageUrl: imageUrl });
            }
        } catch (err) {
            
            console.error('Unsplash fetch failed', err);
        }

        this.showCreateModal = false;
        this.loadItems();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Item created!',
                variant: 'success'
            })
        );
    }, { once: true });
}





   
    openCreateModal() { this.showCreateModal = true; }
    closeCreateModal() { this.showCreateModal = false; }

   
   handleFormSuccess(event) {
    const savedItemId = event.detail.id;

    
    this.showCreateModal = false;
    this.loadItems();

    const itemName = event.detail.fields?.Name || null;

    if (savedItemId && itemName) {
        
        getUnsplashImage({ query: itemName })
            .then(url => {
                if (url) {
                    return updateItemImage(savedItemId, url);
                }
            })
            .catch(err => {
                console.warn('Unsplash error:', err);
            });
    }

    this.dispatchEvent(
        new ShowToastEvent({ title: 'Success', message: 'Item created!', variant: 'success' })
    );
}

   
    get cartLabel() {
    const totalQty = this.cart.reduce(
        (sum, item) => sum + item.quantity,
        0
    );
    return `Cart (${totalQty})`;
}



    get cartTotal()  {
         return this.cart.reduce((sum, i) => sum + i.Price__c * i.quantity, 0); 
     }
    get accountNumberDisplay() {
         return this.account?.data?.fields?.AccountNumber?.value || 'N/A'; 
        }
    get accountIndustryDisplay() {
         return this.account?.data?.fields?.Industry?.value || 'N/A';
         }
}
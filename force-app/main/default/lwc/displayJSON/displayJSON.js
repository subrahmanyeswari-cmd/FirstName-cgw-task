import { LightningElement,api } from 'lwc';
export default class DisplayJSON extends LightningElement {
       @api jsonData;  // Property to hold the passed JSON data

    connectedCallback() {
        // Retrieve the JSON data passed via state
        const urlParams = new URLSearchParams(window.location.search);
        const jsonString = urlParams.get('c__jsonData'); // Get the passed JSON data
    console.log('json -- ',JSON.stringify(jsonString));
        if (jsonString) {
            let jsonData = JSON.parse(jsonString);
            this.jsonData = JSON.stringify(jsonData, null, 2);  // Parse the JSON string into an object
        }
    }

}
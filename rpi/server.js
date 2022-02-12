const { credential } = require('firebase-admin');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const adminCred = require('./your_firebase_admin_credentials.json');  // add firebase admin credentials here
const GPIO = require('onoff').Gpio;  // https://www.npmjs.com/package/onoff

var jobs = new Map();  // Cron jobs

var pins = [];         // GPIO pins array

for (let j = 2; j < 27; j++) {
    pins.push(new GPIO(j, 'out')); // Initialize GPIO pins as output and store them in an array
}

// Initalize Firebase Admin
initializeApp({
    credential: credential.cert(adminCred),
});

const db = getFirestore();

const port_mapping = db.collection('port_mapping');
const cron_jobs = db.collection('cron_jobs');

/* 

    Get all port mappings stored in firestore
    model :
    {

        def_name: String,            // User degined name of the GPIO port
        index: int,                  // Index of the GPIO pin
        status: boolean,             // Status of the GPIO pin (on/off)

    }

*/
port_mapping.orderBy('index', 'asc').onSnapshot((snap) => {
    snap.docChanges().forEach((change) => {

        // Check if any status has changed and update the perticular GPIO pin
        if (change.type === "modified") {
            // Check if the pin is already in that state i.e. if the pin is already on or off 
            if (pins[change.doc.data().index].readSync() != ((change.doc.data().status) ? 1 : 0)) {
                pins[change.doc.data().index].writeSync((change.doc.data().status) ? 1 : 0);   // If not then update the pin
            }
        }
        // Fetch all the port mappings and initalize all the pins - (Initalizes all the pins during startup of the program)
        else {
            // Check if the pin is already in that state i.e. if the pin is already on or off
            if (pins[change.doc.data().index].readSync() != ((change.doc.data().status) ? 1 : 0)) {
                pins[change.doc.data().index].writeSync((change.doc.data().status) ? 1 : 0);   // If not then update the pin
            }  
        }
    });
});


/*

    Get all the cron jobs and store them in a map
    model:
    {

        hour: int,                // Hour of the day
        min: int,                 // Minute of the hour
        index: int,               // Index of the GPIO pin
        port_key: String,         // Key of the port mapping
        status: boolean,          // Status of the GPIO pin (on/off)

    }

*/
cron_jobs.onSnapshot((snap) => {

    // Instead of adding whole collection to the map on every snapshot, add only the changed documents
    snap.docChanges().forEach((change) => {
        if (change.type === "added") {
            let job = { 
                    hour: change.doc.data().hour,
                    min: change.doc.data().min,
                    days: change.doc.data().days,
                    port_key: change.doc.data().port_key,
                    index: change.doc.data().index,
                    status: change.doc.data().status,
                };
            jobs.set(change.doc.id, job);
        }
        if (change.type === "modified") {
            let job = { 
                hour: change.doc.data().hour,
                min: change.doc.data().min,
                days: change.doc.data().days,
                port_key: change.doc.data().port_key,
                index: change.doc.data().index,
                status: change.doc.data().status,
            };
            jobs.set(change.doc.id, job);
        }
        if (change.type === "removed") {
            jobs.delete(change.doc.id);
        }
    });
});


/*

    This function loops every 15 seconds to check if any cron job has to be executed
    Cron job map is implemented for persistency, i.e. even if the server disconnects from the internet the cron jobs will be executed 

*/
setInterval(function() {
    var date = new Date();

    // Iterate through each job and check if the job has to be executed
    // Check the current time and match with the job time and then execute the job
    jobs.forEach(job => {
        if (job.hour === date.getHours() && job.min === date.getMinutes() && job.days[date.getDay()]) {
            
            if (pins[job.index].readSync() != ((job.status) ? 1 : 0)) {
                
                // Update the port status on the firestore to notify the user
                port_mapping.doc(job.port_key).update({status: job.status});
                // Update the GPIO pin
                pins[job.index].writeSync((job.status) ? 1 : 0);

            }

        }
    });
    
}, 15000);
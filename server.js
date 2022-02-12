const { credential } = require('firebase-admin');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const adminCred = require('./your_firebase_admin_credentials.json');  // add firebase admin credentials here
const GPIO = require('onoff').Gpio;

var jobs = new Map();

var pins = [];

for (let j = 0; j < 27; j++) {
    pins.push(new GPIO(j, 'out'));
}

initializeApp({
    credential: credential.cert(adminCred),
});

const db = getFirestore();

const port_mapping = db.collection('port_mapping');
const cron_jobs = db.collection('cron_jobs');

port_mapping.orderBy('index', 'asc').onSnapshot((snap) => {
    snap.docChanges().forEach((change) => {
        if (change.type === "modified") {
            if (pins[change.doc.data().index].readSync() != ((change.doc.data().status) ? 1 : 0)) {
                pins[change.doc.data().index].writeSync((change.doc.data().status) ? 1 : 0);
            }
        }
        else {
            if (pins[change.doc.data().index].readSync() != ((change.doc.data().status) ? 1 : 0)) {
                pins[change.doc.data().index].writeSync((change.doc.data().status) ? 1 : 0);
            }
        }
    });
});


cron_jobs.onSnapshot((snap) => {
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

setInterval(function() {
    var date = new Date();

    jobs.forEach(job => {
        if (job.hour === date.getHours() && job.min === date.getMinutes() && job.days[date.getDay()]) {
            
            if (pins[job.index].readSync() != ((job.status) ? 1 : 0)) {
                
                port_mapping.doc(job.port_key).update({status: job.status});
                pins[job.index].writeSync((job.status) ? 1 : 0);

            }

        }
    });
    
}, 15000);
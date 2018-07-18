const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp(functions.config().firebase)
const ref = admin.database().ref()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.upcomingToCurrent = functions.https.onRequest((req, res) => {
    const currentTime = ((new Date()).getTime())/1000
    var startTime;
    var taskID;
    var hasCurrentTask = false;
    //res.send("Hello from Firebase!");

    ref.child('upcomingTasks').orderByChild('taskTimeMilliseconds').once('value').then(snap => {
        snap.forEach(childSnap => {
            startTime = childSnap.val().taskTimeMilliseconds
            if (childSnap.val().taskTimeMilliseconds <= currentTime){
                hasCurrentTask = true
                taskID = childSnap.val().taskID
                startTime = childSnap.val().taskTimeMilliseconds
                ref.child('upcomingTasks').once('value', function(snap)  {
                    ref.child('currentTasks').child(taskID).update( childSnap.val(), function(error) {
                         if( !error ) {  ref.child('upcomingTasks').child(taskID).remove(); }
                         else if( typeof(console) !== 'undefined' && console.error ) {  console.error(error); }
                    });
               });
            }
            else{
                //return
            }
        })
        res.send("TaskID: "+String(taskID)+" pastTime:"+String(startTime)+ " currentTime:" + String(currentTime) + " " + String(hasCurrentTask))
        return
        }).catch(error => {
            res.send(error)
    })
 });


 exports.currentToPast = functions.https.onRequest((req, res) => {
    const currentTime = ((new Date()).getTime())/1000
    var endTime;
    var taskID;
    var hasPastTask = false;

    ref.child('currentTasks').orderByChild('taskEndTimeMilliseconds').once('value').then(snap => {
        snap.forEach(childSnap => {
            endTime = childSnap.val().taskEndTimeMilliseconds
            if (childSnap.val().taskEndTimeMilliseconds <= currentTime){
                hasPastTask = true
                taskID = childSnap.val().taskID
                endTime = childSnap.val().taskEndTimeMilliseconds
                ref.child('currentTasks').once('value', function(snap)  {
                    ref.child('pastTasks').child(taskID).update( childSnap.val(), function(error) {
                         if( !error ) {  ref.child('currentTasks').child(taskID).remove(); }
                         else if( typeof(console) !== 'undefined' && console.error ) {  console.error(error); }
                    });
               });
            }
            else{
                //return
            }
        })
        res.send("TaskID: "+String(taskID)+" pastTime:"+String(endTime)+ " currentTime:" + String(currentTime) + " " + String(hasPastTask))
        return
        }).catch(error => {
            res.send(error)
    })
 });

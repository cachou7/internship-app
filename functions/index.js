const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp(functions.config().firebase)
const ref = admin.database().ref()

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.upcomingToCurrent = functions.https.onRequest((req, res) => {
    const currentTime = (new Date()).getTime()
    //res.send("Hello from Firebase!");

    ref.child('upcomingTasks').orderByChild('taskTimeMilliseconds').once('value').then(snap => {
        snap.forEach(childSnap => {
            print(ref.child('upcomingTasks'))
            if (childSnap.val().taskTimeMilliseconds >= currentTime){
                //response.send("Database")
                print(childSnap.val().taskTimeMilliseconds)
                const taskID = childSnap.val().taskID
                const taskTimeMilliseconds = childSnap.val().taskTimeMilliseconds
                ref.child('currentTasks').child(taskID).child('taskID').setValue(taskID)
                ref.child('currentTasks').child(taskID).child('taskTimeMilliseconds').setValue(taskTimeMilliseconds)
                ref.child('upcomingTasks').child(taskID).removeValue()
                //return
            }
            else{
                //return
            }
        })
        res.send("Success")
        return
        }).catch(error => {
            res.send(error)
    })
 });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();




exports.onCreateActivityFeedItem = functions.firestore
.document('/feed/{userid}/feeditems/{activityFeedItem}')
.onCreate(async (snapshot, context) =>
{
    const userid = context.params.userid;
    const userRef = admin.firestore().doc(`users/${userid}`);
    const doc = await userRef.get();


    const androidNotificationToken = doc.data().androidNotificationToken;
    const createActivityFeedItem = snapshot.data();

    if(androidNotificationToken)
    {
        sendNotification(androidNotificationToken, createActivityFeedItem);
    }
    else
    {
        console.log("No token for user, can not send notification.")
    }

    function sendNotification(androidNotificationToken, activityFeedItem)
    {
        let body;

        switch (activityFeedItem.type)
        {
            case "comment":
                body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
                break;

            case "like":
                body = `${activityFeedItem.username} liked your post`;
                break;

            case "follow":
                body = `${activityFeedItem.username} started following you`;
                break;

            default:
            break;
        }

        const message =
        {
            notification: { body },
            token: androidNotificationToken,
            data: { recipient: userid },
        };

        admin.messaging().send(message)
        .then(response =>
        {
            console.log("Successfully sent message", response);
        })
        .catch(error =>
        {
            console.log("Error sending message", error);
        })

    }
});




exports.onCreateFollower = functions.firestore
  .document("/followers/{userid}/userfollowers/{followerId}")
  .onCreate(async (snapshot, context) => {

    console.log("Follower Created", snapshot.id);

    const userid = context.params.userid;

    const followerId = context.params.followerId;

    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userid)
      .collection("usersposts");

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    const querySnapshot = await followedUserPostsRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postid = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postid).set(postData);
      }
    });
  });





  exports.onDeleteFollower = functions.firestore
  .document("/followers/{userid}/userfollowers/{followerId}")
  .onDelete(async (snapshot, context) => {

    console.log("Follower Deleted", snapshot.id);

    const userid = context.params.userid;

    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userid);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists)
      {
        doc.ref.delete();
      }
    });
  });





exports.onCreatePost = functions.firestore
  .document("/posts/{userid}/usersposts/{postid}")
  .onCreate(async (snapshot, context) => {

    const postCreated = snapshot.data();

    const userid = context.params.userid;

    const postid = context.params.postid;

    const userfollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userid)
      .collection("userfollowers");

    const querySnapshot = await userfollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postid)
        .set(postCreated);
    });
  });





exports.onUpdatePost = functions.firestore
  .document("/posts/{userid}/usersposts/{postid}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userid = context.params.userid;
    const postid = context.params.postid;

    const userfollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userid)
      .collection("userfollowers");

    const querySnapshot = await userfollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postid)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });





exports.onDeletePost = functions.firestore
  .document("/posts/{userid}/usersposts/{postid}")
  .onDelete(async (snapshot, context) => {
    const userid = context.params.userid;
    const postid = context.params.postid;

    const userfollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userid)
      .collection("userfollowers");

    const querySnapshot = await userfollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postid)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB-dOZh9vXhi9_Hv9dGNc6vXDYW6RlNP7w",
  authDomain: "jewelofasia-1d8c1-d564b.firebaseapp.com",
  projectId: "jewelofasia-1d8c1",
  storageBucket: "jewelofasia-1d8c1.appspot.com",
  messagingSenderId: "575307389937",
  appId: "1:575307389937:web:5f0442d85bb3d3dcc68250",
  measurementId: "G-ZPEXM8DCFX"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
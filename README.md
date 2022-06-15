## Dinar - دینار
![dinar logo](https://github.com/hedihadi/dinar/raw/master/assets/images/ic_launcher.png)


###### it's production-ready for Android only! not tested on IOS as i don't have unlimited money to buy a  Mac and an Iphone.
\
\
###### The application uses Firebase as the backend database.
###### i have implemented a simple technique to reduce load on the database.
![screenshot of my database](https://github.com/hedihadi/dinar/raw/master/assets/readme.png)
###### in above image, there's a variable called "update", i randomly generate a new number and update this variable whenever i make a change to my database;
###### and when the user opens the app, it checks if this variable is changed, if it's not changed then it simply uses the cached data.

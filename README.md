# Introduction
The FaceBit Companion App is a iOS/macOS application that manages sensor data from a FaceBit device. The app collects, stores, and processes data into insights that can be presented to the user of FaceBit. 

The application is built as a [Catalyst](https://developer.apple.com/mac-catalyst/) application which allows the same code to run on both iOS and MacOS. 

# MacOS App
## Running macOS Application (No XCode- Release)
* Download the latest version from the Releases section of this repository.
    * May require security permission. System Preferences->Security & Privacy->General->Allow Applications

## Running MacOS Application (XCode - Development)
1. On macOS 11+, download the latest version of XCode from the AppStore
2. Clone this repository
3. Open `app/FaceBit Companion.xcode.proj` in XCode
4. Update the app signing to your Apple Id
5. Select **My Mac** from the device drop down in XCode's tool bar.
6. Run using **Cmd+r** or run button in the top left.
![xcode-signing](resources/imgs/xcode-signing.png)

# iOS App
## Running iOS Application (No XCode - Release)
* on a iOS Device, download TestFlight from the AppStore
* Slack Blaine to add you to the app team as a Developer
* Accept the invite via email on your iOS Device
* Download the app via TestFlight (should receive notification for new builds)
![testflight](resources/imgs/testflight.jpeg)

## Running on iOS Application (XCode - Development)
**Note**: Requires a active [Apple Developer Account](https://developer.apple.com/)

**Note**: Bluetooth is not supported on iOS Simulators. The application will run on a simulator but you will not be able to interact with the FaceBit Sensor Board.


Follow the same steps as running the MacOS Application, but instead of selecting **My Mac**, connect your physical iPhone and select it from the  device drop down in XCode's tool bar.

![xcode-iphone-select](resources/imgs/xcode-iphone-select.png)

# App Functionality
## Homepage
The homepage contains a demonstration of a consumer application, displaying high level information about the device and health metrics. More widget can be developed by exploring the code in `Views/MyFaceBit/Metrics`.

## Connect FaceBit Sensor
Following instruction in the [Embedded Firmware repository](https://gitlab.com/ka-moamoa/smart-ppe/embedded-firmware) for setting up the FaceBit Sensor. 
* Upon app start the device will search for the FaceBit device (broadcasted name `SMARTPPE`)
* The home page will display `active` when connected and the status indication will be filled.
* To reconnect, press the status indication to start the bluetooth search.
![facebit-connected](resources/imgs/macos-facebit-connected.png)


## Data Collection
Data is stored in a local SQLite database. Raw readings on the device are stored in a transactional table. To explore the database open the settings tab and select **Open SQL Database** (macOS) or **Share SQLite Database** (iOS). [SQLite DB Browser](https://sqlitebrowser.org/) is a free cross-platform application for interfacing with SQLite Databases.
![settings](resources/imgs/settings.png)

### Event Recording
Event recording is used to tag data with events for data exploration. Access event recording from **Settings->Record Events** with the FaceBit Sensor Board connected. Enter event metadata and press **Start Event**. Perform the event (e.g. Deep Breathing) and then select **Stop Event**. 

When a event is started a new event record is stored in the database. When Stopped, all transactional recording between the start and end time are updated (tagged) with the event. See the Python exploration below for accessing events and plotting.
![event-recoding](resources/imgs/event-recording.png)
![normal-breathing](resources/imgs/normal_breathing_2.png)

# Data Exploration
SQLite was selected as the datastore for easy access to any programming language or tool for data exploration. 

## Python
`data-exploration/` contains a Jupyter Notebook for reading a SQLite Database and plotting temperature and pressure data of all event. To Run: 
* Create a new Python environment
    * e.g. from the `data-exploration` directory, run: `conda env create -f env.yml`
* Open the jupyter notebook:
    * With [Visual Studio Code](https://code.visualstudio.com/docs/python/jupyter-support)
    * With Jupyter server: run `jupyter notebook` from the `data-exploration` directory.
* Update database path in the first cell of the notebook
    * **Note**: if using macOS just update the username.


# Troubleshooting
## MacOS Version
Since the application is built using [Catalyst](https://developer.apple.com/mac-catalyst/) which is a new feature of Apple ecosystem development, macOS Big Sur (11) is required to run the application on Mac.

## MacOS Running
Occasionally when developing on macOS, The application does not properly close when stopping the application in Xcode and the following error is displayed. To fix, open Activity Monitor and search `facebit` and force quit the application.
![xcode-app-running-error](resources/imgs/xcode-app-running-error.png)
![activty-monitor-facebit](resources/imgs/activity-monitor-facebit.png)

## Barometer Initialization
Currently, there is a issue with the barometer initializing on the FaceBit Sensor Board. For the best results, run the device using J-Link and powered by battery. Once running, you can disconnect the device from the J-Link.
# Processing Support

Extension for [Brackets](https://github.com/adobe/brackets/).

Add support Processing language, and commands that create new sketch and run a sketch.

## Feature
- Add support language
- Add Processing menu
 - New Sketch
 - Run (Keyboard shortcut: F7)
 - Stop
 - Config
- Add code hinting

## Installation

1. Open the **Extensions Manager**
2. Search for "processing support"
3. Click the **Install** button
4. [Connect to Processing](#Connect-to-Processing)

### Connect to Processing
This extension uses "processing-java(.exe)" that the command line tool in installed Processing.
Running a sketch required follow steps.

#### Mac
1. Open Processing app
2. Select menu **Install "processing-java"** from the menu **Tools**
3. Click **Yes** or **No** to install
4. Open Brackets app
5. Select **Config** from the menu **Processing**
6. Input the path for "processing-java"
 - /usr/local/bin/processing-java (when you select **Yes**. Default path)
 - /Users/mikankari/processing-java (when you select **No**. Replace "mikankari" to your name)
7. Click the **Save** button

#### Windows or Linux
1. Select **Config** from the menu **Processing**
2. Input the path for "processing-java(.exe)" in installed Processing directory
 - C:\Users\mikankari\Program Files\processing-3.3.5\processing-java.exe (Example for Windows)
 - /home/mikankari/opt/processing-3.3.5/processing-java (Example for Ubuntu)
3. Click the **Save** button

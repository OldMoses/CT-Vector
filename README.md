# CT-Vector
A 1000 second turn based ship vector utility, written in QB64

DEVELOPMENT AND USE NOTES:

CT Vector is coded in QB64 version 1.5 (obtainable from qb64.org). Because of its
use of the latest functionality in its basic structure, particularly the new 
BIT operators and dimension syntax, it will require at least version 1.5 to compile.

INSTALLATION:

Step 1:
Unzip CT Vector
Extract the contents of the zip file to the desired root directory. The application
does not alter the system registry in any way and will run from any directory of the
users choosing. After the files are extracted, it will be necessary to compile the 
.bas files using the QB64 IDE. 

Step 2:
Run QB64

Step 3:
First insure that QB64 will save the executables to the right place by choosing "Run"
in the IDE's menu bar and enabling "Output EXE to Source Folder", otherwise QB64 will
place the executables in its own root directory and the application will not be able
to find its support files.

Step 4:
Then go to "File" and choose "Open" to access QB64's retro-DOS looking open dialog box.
Navigate to the root folder where you unzipped the application and choose 'ctvector###.bas'
or 'sysinput###.bas' as desired.

Step 5:
Once loaded the programs can be run by either choosing "Run" then choosing "Start" in the 
Run dropdown, or pressing the F5 key. Once run the first time, and if all went correctly, 
CTVector and/or SysInput executables should now be in your installed root directory.


FILE STRUCTURE: 
The following must be present for proper function, autosave functions 
will create ..\scenarios\autosave automatically if they are not already present.
The user is responsible for keeping track of additional subdirectories, such as
sector and/or subsector arrangements.

root directory\

    		images\
			arialbd.ttf
			disabled.png
			flag.png
			moon1.jpg
			ovrthrust.png
			slave.png
			starfield.jpg
			suleimano.png
			thrust.png
			timesbd.ttf
			tlock.png
			trnsp0.png
			trnsp1.png
			tunlock.png
		
		include\
			getopen.bas
			pipecomqb64.bas

    		scenarios\
			demo.tfs
			demo2.tfs

    			 autosave\
				auto.tfs (not present on installation, present after run)
    		ships\
			demo.tvg

    		systems\
			Beta Orionis.tss
			hebrin1930.tss
			prometheus.tss
			regina.tss
			sol.tss <--this is the default load system

		context.txt
		ctvector###.bas
		default.ini
		readmectv.txt
		sysinput###.bas


NOTES:
Once created, the primary executables; ctvector###.exe and sysinput###.exe 
should reside in the root directory. They will look for the necessary files
in the subdirectories.

Several stellar systems are included in the 'systems\' directory which the user
may use to familiarize themselves with the applications, however it might 
avoid default loading problems if some form of "sol.tss" remains rooted in the
systems\ location. It may be edited as desired through SysInput, as long as it
is present.

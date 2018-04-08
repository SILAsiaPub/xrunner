# Xrunner

Xrunner is a GUI to run projects that would be batch files that may be simple transformations or complex projects. It is setup to run XSLT transformations but can run any commandline tool. It is designed to have simpler syntax than batch files.

## Setting up a simple project

* You create a folder in the Projects folder. 
* Within that folder create a plain text file called project.txt.
* Define your variables.

``` 
sourcexml=%projectpath%\source\data.xml
outxml=%projectpath%\output\new-data.xml
```
* Define your tasks to run

``` 
taska1=:xslt transfom.xslt "%sourcexml%"
taska2=:cct changetable.cct "" "%outxml%"
```

or it can be written

``` 
taska1=:var inputfile "%sourcexml%"
taska2=:xslt transfom.xslt
taska3=:cct changetable.cct
taska4=:outputfile "%outxml%"
```

* In *taska1* the of the first example has no output file specified because the file naming will happen automatically. In the second *taska2* the empty double quotes use the output from the previous.
* The second example demonstrates how you can just specify the start and end file and have the file passed to the next task without worrying about the naming.
* There can be many tasks but 10 are handled by default for each group of the predefined groups a-f. So taska1 is the first task in group a. You are not limited to 10 you can increase that in either your *project.txt* file or by changing the *C:\ProgramData\xrun\xrun.ini* file.
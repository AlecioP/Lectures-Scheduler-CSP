# Lectures-Scheduler-CSP
Minizinc program to model a scheduling of lectures within a conference. Each conference has an host who can also attend to other lectures. The model tries to maximize the overall satisfaction of each person attending the conference. The satisfaction is based on the interest each person expresses _a priori_ to each lecture. The final user of the model can define the number of days available for the conference, the number of rooms available each day and the time available each day. The user can also define a break during each day.



_End course project for Artificial Intelligence exam (Master degree in Computer science @unibo.it)_

# Input data for _Minizinc_ model

Input data should look like this : 

```

% Start is at 9:00 
% Break is at 13:00
% End of break is at 14:00
% End of the event is at 17:00
Break = 240; % [13-9 = 4]*60 (minutes per hour) = 240 
End = 300; % [14-9 = 5]* 60 = 300
Noon = 480; % [17-9 = 8] * 60 = 480 
P=21;
N=21;
X=2;
Y=4;
H=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21];
Len=[55,55,90,120,135,140,60,90,105,140,40,75,90,95,100,140,60,60,90,120,140];

I=[|4,0,5,4,5,5,4,5,3,1,0,5,2,3,3,0,3,3,5,3,4,|
    5,0,2,2,1,4,5,0,3,1,4,3,1,2,4,3,0,3,5,2,5,|
    3,4,1,0,5,1,5,3,5,2,2,1,0,4,3,1,0,4,5,3,1,|
    1,4,5,5,1,1,4,1,2,3,2,3,4,3,0,4,3,2,3,4,3,|
    5,5,3,2,2,2,2,2,2,4,4,4,5,3,0,5,2,5,2,2,1,|
    0,0,0,5,0,3,1,0,2,4,3,1,1,3,4,5,0,2,3,0,3,|
    2,3,0,0,0,1,2,1,4,4,0,5,0,1,3,3,5,3,0,1,2,|
    4,0,1,1,1,0,2,1,5,3,0,5,4,4,3,5,4,4,3,4,2,|
    4,5,4,3,5,3,2,0,3,1,0,4,0,4,2,0,1,2,2,1,3,|
    2,2,2,3,3,4,0,2,1,4,1,3,5,1,1,1,5,3,3,1,5,|
    1,5,3,3,4,2,0,4,1,4,5,4,0,5,0,1,0,1,3,4,1,|
    0,0,3,1,4,0,3,0,1,1,4,5,0,2,4,4,3,2,1,2,4,|
    1,2,0,0,4,5,5,3,4,0,4,4,4,2,1,0,3,3,2,0,2,|
    4,0,4,3,5,2,3,4,4,1,0,3,3,2,5,3,0,5,2,4,1,|
    0,1,0,4,1,1,4,4,4,3,4,5,3,4,3,3,1,3,5,5,1,|
    2,1,0,3,1,5,3,4,5,3,5,2,4,1,3,4,1,0,5,0,4,|
    2,0,2,2,1,0,2,1,2,3,5,3,3,1,4,2,5,3,4,3,2,|
    5,2,0,2,4,4,0,1,1,1,5,4,2,1,2,0,2,0,4,5,5,|
    2,2,1,3,4,4,4,4,1,4,2,4,1,1,1,0,0,3,4,1,2,|
    2,1,3,0,3,5,2,5,4,5,1,1,5,2,4,5,3,3,2,2,2,|
    1,2,1,5,0,1,2,2,1,5,5,5,5,5,5,0,5,3,1,2,4|];

```

# File _util/renderSchedule.py_

Utility to help visualizing the output schedule. The input file to the script should be a CSV named _minizinc.csv_ containing `3` lines each containing `N` values:
- First line is the array containing the length of each event (`Len`);
- Second line is the array containing the scheduling day of the event (`D`);
- Third line is the array containing the position of the event in the day (`M`);

`Note` : The script only works if the model has the number of rooms available `X` set to `1`.

%%%%%%%%%%%%%%%%%%%%%%%%%-----MODEL-PARAMETERS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Start of the Break
int : Break;
%End of the Break
int : End;
%End of the day
int : Noon;
%Total number of presentations
int: N;
%Total number of available meeting rooms
int: X;
%Total number of available days
int: Y;
%Presentations duration
array[1..N]of int : Len;
%Number of participants 
int: P;
%Interest matrix foreach participant and each event
array[1..P,1..N]of 0..5: I;
%ID of presenter for each event
array[1..N] of 1..P: H;
%Total of events lengths
int : totLen = sum(i in 1..N)(Len[i]);
%Length of shortest event
int : Shortest;
%Max number of events which can fit in a single day and room
int : Max_per_day = (Noon-(End-Break)) div Shortest;

%%%%%%%%%%%%%%%%%%%%%%%%%-----ASSERTION-ON-PARAMETERS-----%%%%%%%%%%%%%%%%%%%%%%%%%

constraint forall(i in 1..N)(assert(Len[i]>=Shortest,"Error : Shortest param wrong"));
constraint assert(N>0,"Error: num presentations <=0");
constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days <=0");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));
constraint assert((Y*X*(Noon-60))>=totLen,"Error sum of events lengths is too long");
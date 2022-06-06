include "lib.mzn";
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

%%%%%%%%%%%%%%%%%%%%%%%%%-----DECISION-VARIABLES-----%%%%%%%%%%%%%%%%%%%%%%%%%

%The day assigned to each presentation
array[1..N]of var 1..Y: D;
%Ordering position of the event in the day
array[1..N]of var 1..Max_per_day: M;
%Room assigned to each event
array[1..N]of var 1..X: R;

%%%%%%%%%%%%%%%%%%%%%%%%%-----ASSERTION-ON-PARAMETERS-----%%%%%%%%%%%%%%%%%%%%%%%%%

constraint forall(i in 1..N)(assert(Len[i]>=Shortest,"Error : Shortest param wrong"));
constraint assert(N>0,"Error: num presentations <=0");
constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days <=0");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));
constraint assert((Y*X*(Noon-60))>=totLen,"Error sum of events lengths is too long");

%%%%%%%%%%%%%%%%%%%%%%%%%-----SATISFACTION CONSTRAINTS-----%%%%%%%%%%%%%%%%%%%%%%%%%

constraint exists(ev in 1..N)(D[ev]=1 /\ M[ev]=1 /\ R[ev]=1);

constraint forall(e1 in 1..N, e2 in 1..N where e1<e2 /\ D[e1]=D[e2] /\ R[e1]=R[e2] )( M[e1]!=M[e2]);

constraint forall(ev in 1..N)(
  sum(ev1 in 1..N)
    (if D[ev1]=D[ev] /\ R[ev1]=R[ev] /\ in_morning(ev1) then Len[ev1] else 0 endif) <= (Break)
  /\
  sum(ev2 in 1..N)
    (if D[ev2]=D[ev] /\ R[ev2]=R[ev] /\ not in_morning(ev2) then Len[ev2] else 0 endif) <= (Noon-End)
);

constraint forall(e in 1..N)(
  if is_last_day(e) then 
    forall(pos in 1..M[e])(exists(ev in 1..N)(D[ev]=D[e] /\ R[ev]=R[e] /\ M[ev]=pos))
  endif
);

solve satisfy; 

output [show(Max_per_day)++"\n"++show(Len)++"\n"++show(D)++"\n"++show(M)++"\n"];
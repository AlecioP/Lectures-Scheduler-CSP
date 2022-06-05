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

%%%%%%%%%%%%%%%%%%%%%%%%%-----DECISION-VARIABLES-----%%%%%%%%%%%%%%%%%%%%%%%%%

%The day assigned to each presentation
array[1..N]of var 1..Y: D;
%Ordering position of the event in the day
array[1..N]of var 1..N: M;
%Room assigned to each event
array[1..N]of var 1..X: R;

%%%%%%%%%%%%%%%%%%%%%%%%%-----ASSERTION-ON-PARAMETERS-----%%%%%%%%%%%%%%%%%%%%%%%%%

constraint assert(N>0,"Error: num presentations <=0");
constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days <=0");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));

constraint assert((Y*X*(Noon-60))>=totLen,"Error sum of events lengths is too long");
%%%%%%%%%%%%%%%%%%%%%%%%%-----SATISFACTION CONSTRAINTS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%All different in the same day (i<j to break symmetry)
constraint forall(i in 1..N,j in 1..N where i<j /\ D[i]=D[j] /\ R[i]=R[j] )( M[i]!=M[j]);

% Force using first day available
% Force using continuos days from the first on

constraint exists(ev in 1..N)(D[ev]=1);%Assume there is always some event which length is smaller than Break

constraint forall(ev in 1..N where D[ev]>1)( %If exists an event not scheduled in first day 
  exists(ev1 in 1..N)(D[ev1]=D[ev]-1) % and also one per day until the day of EV
);

% Force assign first position of the day for each room and day
% Force assign continuos positions from the first on

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  exists(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room)(M[ev1]=1) /\
  if M[ev]>1 then exists(ev2 in 1..N where D[ev2] = day /\ R[ev2] = room)(M[ev2]=M[ev]-1) endif
);

%Total len sum in a day and room fits in available time in each day

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  sum(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room)(Len[ev1]) <= (Noon-60)
);

%Break constraint

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  forall(ev1 in 1..N where D[ev1]= day /\ R[ev1]=room /\ is_first_afternoon(ev1))(
    sum(ev2 in 1..N where D[ev2]=day /\ R[ev2]=room /\ M[ev2]>=M[ev])(Len[ev2]) <= (Noon-End)
  )
);

%Shouldn't exist such event which can fit into the end of the day but is scheduled next day

constraint forall(e in 1..N)(let {var int : day = D[e]; var int : room = R[e] } in 
  if not exists(ev1 in 1..N)(D[ev1]=day /\ R[ev1]=room /\ M[ev1]>M[e]) then 
    not exists(ev2 in 1..N where D[ev2]>day \/ R[ev2]>room)(Len[ev2]<= Noon-start(e))
  endif
);

%

% ONLY ONE OF THE FOLLOWING TWO LINES
% (Can't find a way to conditional compile)
solve satisfy; 

%include "Preference-constraints.mzn";
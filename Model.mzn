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
%Upper bound to objective function
int : maxInterest = sum(i in 1..P,j in 1..N)(I[i,j]);
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

constraint assert(P<=N,"Error : num presenters more than presentations");
constraint assert(P>0,"Error: num presenters <=0");
constraint assert(N>0,"Error: num presentations <=0");
constraint assert(X>0,"Error: num rooms");
constraint assert(Y>0,"Error: num days <=0");
constraint forall(i in 1..N)(assert(Len[i]>0,"Error: Len"++show(i)));

%%%%%%%%%%%%%%%%%%%%%%%%%-----SATISFACTION CONSTRAINTS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%All different in the same day (i<j to break symmetry)
constraint forall(i in 1..N,j in 1..N where D[i]=D[j] /\ R[i]=R[j] /\ i<j)( M[i]!=M[j]);



% Force assign first position of the day for each room and day
% Force assign continuos positions from the first on

constraint forall(day in 1..Y,room in 1..X)(
  forall(ev in 1..N where D[ev]=day /\ R[ev]=room /\ M[ev]>1)(
    exists(ev1 in 1..N)(D[ev1]=day /\ R[ev1]=room /\ M[ev1]=(M[ev]-1)) /\
    exists(ev2 in 1..N)(D[ev2]=day /\ R[ev2]=room /\ M[ev2]=1)
  )
);


%Total len sum in a day and room fits in available time in each day
constraint forall(day in 1..Y,room in 1..X)( %for each day AND for each room
        sum(ev in 1..N)(if D[ev]=day /\ R[ev]=room then Len[ev] else 0 endif )<= (Noon-60)
);


%Break constraint
constraint forall(day in 1..Y,room in 1..X)(
  forall(ev in 1..N where D[ev] = day /\ R[ev] = room /\ is_first_afternoon(ev))(
    sum(ev1 in 1..N where D[ev1]=day /\ R[ev1] = room /\ M[ev1]>=M[ev])(Len[ev1]) <= Noon-End
  )
);


% Make sure the total time available is enough to fit every event 
constraint (Y*X*(Noon-60))>totLen;

% Force using first day available
% Force using continuos days from the first on

constraint forall(ev in 1..N where D[ev]>1)( %If an event is not scheduled in first day 
  exists(ev2 in 1..N)(D[ev]=1) /\ % At least one should be scheduled into first day
  exists(ev1 in 1..N)(D[ev]=D[ev1]+1) % and also one per day until the day of EV
);

constraint forall(day in 1..Y,room in 1..X)(
  forall(ev in 1..N where D[ev]=day /\ R[ev]=room)(
   if not exists(ev1 in 1..N)(D[ev1]=day /\ R[ev1]=room /\ M[ev1]>M[ev]) then 
    not exists(ev2 in 1..N where D[ev2]>day \/ R[ev2]>room)(Len[ev2]<= Noon-start(ev))
   endif
  )
);


% ONLY ONE OF THE FOLLOWING TWO LINES
% (Can't find a way to conditional compile)
solve satisfy; 

%include "Preference-constraints.mzn";
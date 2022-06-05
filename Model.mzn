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
constraint exists(ev in 1..N)(D[ev]=1 /\ M[ev]=1 /\ R[ev]=1);

constraint forall(e1 in 1..N, e2 in 1..N where e1<e2 /\ D[e1]=D[e2] /\ R[e1]=R[e2] )( M[e1]!=M[e2]);

constraint continuity();

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  sum(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room)(Len[ev1]) <= (Noon-60)
);

constraint forall(ev in 1..N where D[ev]>1)( 
  forall(room in 1..X)(
    exists(ev1 in 1..N)(D[ev1]=D[ev]-1 /\ M[ev1]=1 /\ R[ev1]=room) 
  ) /\
  forall(room1 in 1..R[ev])( 
    exists(ev2 in 1..N)(D[ev2]=D[ev] /\ R[ev2]=room1 /\ M[ev2]=1)
  )
);

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  exists(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room)(M[ev1]=1) /\
  if M[ev]>1 then exists(ev2 in 1..N where D[ev2] = day /\ R[ev2] = room)(M[ev2]=M[ev]-1) endif
);

constraint forall(ev in 1..N)(let {var int : day = D[ev]; var int : room = R[ev] } in 
  forall(ev1 in 1..N where D[ev1]= day /\ R[ev1]=room /\ is_first_afternoon(ev1))(
    sum(ev2 in 1..N where D[ev2]=day /\ R[ev2]=room /\ M[ev2]>=M[ev])(Len[ev2]) <= (Noon-End)
  )
);

constraint forall(e in 1..N)(let {var int : day = D[e]; var int : room = R[e] } in 
  if is_last_day(e) then 
    not exists(ev2 in 1..N where D[ev2]>day \/ R[ev2]>room)(Len[ev2]<= Noon-finish(e))
  endif
);

solve satisfy; 
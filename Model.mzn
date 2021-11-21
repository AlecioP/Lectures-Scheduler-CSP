%%%%%%%%%%%%%%%%%%%%%%%%%-----MODEL-PARAMETERS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Start of the Break
int : Break;
%End of the Break
int : End;
%Total time after the break
int : Noon = End-Break;
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

%%%%%%%%%%%%%%%%%%%%%%%%%-----DECISION-VARIABLES-----%%%%%%%%%%%%%%%%%%%%%%%%%

%The day assigned to each presentation
array[1..N]of var 1..Y: D;
%Ordering position of the event in the day
array[1..N]of var 1..N: M;
%Room assigned to each event
array[1..N]of var 1..X: R;
%Matrix of the choices for each participant and each event
array[1..P,1..N]of var 0..1 : Choice;
%Total satisfaction of participants
var int : score;

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
%No solution where exists one day with M containing 3 and 5 but not 4 
constraint forall(day in 1..Y)(forall(room in 1..X)(
forall(ev in 1..N where D[ev]=day /\ R[ev]=room)(
if not exists(ev1 in 1..N)(D[ev]=D[ev1] /\ R[ev]=R[ev1] /\ M[ev1]=M[ev]+1) then
      not exists(ev2 in 1..N)(D[ev]=D[ev2] /\ R[ev]=R[ev2] /\ M[ev2]>M[ev]) 
endif
)
));
%No solution where exists one day with M containing 2 but not 1
constraint forall(day in 1..Y)(forall(room in 1..X)(
if exists(ev in 1..N)(D[ev]=day /\ R[ev]=room)then
    exists(ev1 in 1..N)(D[ev1]=day /\ R[ev1]=room /\ M[ev1]=1)
endif
));

%Total len sum in a day and room
constraint forall(i in 1..Y)(forall(r in 1..X)(
        sum(j in 1..N)(if D[j]=i /\ R[j]=r then Len[j] else 0 endif )<End
));

%Break constraint
constraint forall(i in 1..Y)(forall(r in 1..X)(
      forall(j in 1..N where D[j]=i /\ R[j]=r)(
      let{var int : partial = sum(x in 1..N)(if D[j]=D[x] /\ R[j]=R[x] /\ M[x]<M[j] then Len[x]else 0 endif)}in
         if partial < Break /\ partial+Len[j]>=Break then
               /*(240-partial)+ */
               sum(z in 1..N)(if D[j]==D[z] /\ R[j]=R[z]  /\ M[z]>=M[j] then Len[z] else 0 endif)<Noon
         endif
      )
   )
);

%%%%%%%%%%%%%%%%%%%%%%%%%-----CONSTRAINTS-TO-MAXIMIZE-OBJECTIVE-----%%%%%%%%%%%%%%%%%%%%%%%%%

/*
If two events are presented by the same person, 
they cannot be in the same day and time but different room
*/
constraint 
forall(ev1 in 1..N,ev2 in 1..N where ev1<ev2 /\ H[ev1]=H[ev2] /\ D[ev1]=D[ev2] /\ R[ev1]!=R[ev2])(
let{
    var int : start1 = start(ev1);
    var int : start2 = start(ev2);
}in
(start1+Len[ev1]<=start2 ) \/ (start2+Len[ev2]<=start1)
      
);

%Each presenter must participate to its own event
constraint forall(i in 1..N)(
  Choice[H[i],i]=1
);


/*
One cannot attend two events in the same day 
and same time, whether they are in the same room 
or not
*/
constraint forall(part in 1..P)(
forall(ev1 in 1..N,ev2 in 1..N where ev1<ev2 /\ Choice[part,ev1]=1 /\ Choice[part,ev2]=1)(
D[ev1]!=D[ev2] \/ start(ev1)+Len[ev1]<=start(ev2) \/ start(ev2)+Len[ev2]<=start(ev1)
)
);
/*
If one attends an event at a given day and time, 
he cannot attend any other event at the same day 
and time
*/
constraint forall(part in 1..P)(
forall(ev1 in 1..N,ev2 in 1..N where ev1<ev2 /\ D[ev1]=D[ev2] /\ ((start(ev1)>=start(ev2)/\ start(ev1)<start(ev2)+Len[ev2]) \/ (start(ev2)>=start(ev1)/\ start(ev2)<start(ev1)+Len[ev1]) ))(
if Choice[part,ev1]=1 then Choice[part,ev2]=0 endif /\ if Choice[part,ev2]=1 then Choice[part,ev1]=0 endif
)
);
constraint (Y*X*End)>sum(i in 1..N)(Len[i]);


%%%%%%%%%%%%%%%%%%%%%%%%%-----OBJECTIVE-FUNCTION-----%%%%%%%%%%%%%%%%%%%%%%%%%
constraint 
    score = sum(part in 1..P)(sum(ev in 1..N)(
         Choice[part,ev]*I[part,ev]
    ))
;

constraint score < maxInterest;
solve maximize score;

%%%%%%%%%%%%%%%%%%%%%%%%%-----UTIL-FUNCTIONS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Function to compute the start time of an event
function var int: start(int: ev ) =(
      let{
      /*
      Time difference left between the start 
      of the break and the last event in the morning
      */
        var int : gap = Break - sum(ev1 in 1..N)(
          if D[ev1]=D[ev] /\ R[ev1]=R[ev] then
            let{
              /*
              Sum of the lens of each event 
              preciding ev1 in the same day and room
              */
              var int : part = sum(ev2 in 1..N)(if D[ev2]=D[ev] /\ R[ev2]=R[ev] /\ M[ev2]<M[ev1] then Len[ev2] else 0 endif);
              }in
                /*Ev1 is the one which cannot be scheduled 
                in the morning due to its len. Therefore
                it needs to be moved at 2:00 pm leaving an empty
                time slot between the start of the break and its previous
                starting time
                */
                if part < Break /\ part+Len[ev1]>=Break then part else 0 endif 
          else 
            0
          endif
        );%Var GAP
        /*
        The starting time of the event considered, 
        without counting the break issue
        */
        var int : currentpart = sum(ev1 in 1..N)( if D[ev1]=D[ev] /\ R[ev1]=R[ev] /\ M[ev1]<M[ev] then Len[ev1] else 0 endif);
      }in
        /*
        Ev cannot be scheduled in the morning therefore 
        its starting time is moved of |gap| minutes
        */
        if(currentpart+Len[ev]>=Break)then
          currentpart+gap
        else
          currentpart
        endif
);
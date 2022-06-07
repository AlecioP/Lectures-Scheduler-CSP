%%%%%%%%%%%%%%%%%%%%%%%%%-----MODEL-PARAMETERS-(2)------%%%%%%%%%%%%%%%%%%%%%%%%%

%Upper bound to objective function
int : maxInterest = sum(i in 1..P,j in 1..N)(I[i,j]);

%%%%%%%%%%%%%%%%%%%%%%%%%-----ASSERTION-ON-PARAMETERS-(2)-----%%%%%%%%%%%%%%%%%%%%%%%%%

constraint assert(P<=N,"Error : num presenters more than presentations");
constraint assert(P>0,"Error: num presenters <=0");

%%%%%%%%%%%%%%%%%%%%%%%%%-----DECISION-VARIABLES-(2)-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Matrix of the choices for each participant and each event
array[1..P,1..N]of var 0..1 : Choice;
%Total satisfaction of participants
var int : score;
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




%%%%%%%%%%%%%%%%%%%%%%%%%-----OBJECTIVE-FUNCTION-----%%%%%%%%%%%%%%%%%%%%%%%%%
constraint 
    score = sum(part in 1..P)(sum(ev in 1..N)(
         Choice[part,ev]*I[part,ev]
    ))
;

constraint score < maxInterest;
solve ::int_search(D, first_fail, indomain_min) ::int_search(M, first_fail, indomain_min) maximize score;
output [show(score)++"\n"++show(Max_per_day)++"\n"++show(Len)++"\n"++show(D)++"\n"++show(M)++"\n"];

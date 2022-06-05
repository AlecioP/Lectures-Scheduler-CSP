%%%%%%%%%%%%%%%%%%%%%%%%%-----UTIL-FUNCTIONS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Function to compute the start time of an event
function var int: start(var int: ev ) =(
  let {
    var int : day = D[ev];
    var int : room = R[ev];
    var int : len = Len[ev];
    var int : pos = M[ev];
    var int : timebefore =
      sum(ev1 in 1..N)( if D[ev1]=day /\ R[ev1]=room /\ M[ev1]<pos then Len[ev1] else 0 endif);
  }in
    if (timebefore + len) <= Break
      then
        timebefore
      else
        if timebefore <= Break
          then
            End
          else
            let{
              
              % The index of the first event in the afternoon
              var int : index = 
                sum(ev2 in 1..N)(if D[ev2]=day /\ R[ev2]=room /\ is_first_afternoon(ev2) then ev2 else 0 endif);
              var int : pos1 = M[index];
              var int : timebefore1 = sum(ev3 in 1..N)(if D[ev3]=day /\ R[ev3]=room /\ M[ev3]>=pos1 /\ M[ev3] < pos then Len[ev3] else 0 endif);
            } in 
              (End + timebefore1)
        endif
    endif  
);

function var int : finish(var int : ev) = start(ev)+Len[ev];

predicate is_first_afternoon(var int : ev) = (
    let {
    var int : day = D[ev];
    var int : room = R[ev];
    var int : len = Len[ev];
    var int : pos = M[ev];
    var int : timebefore =
      sum(ev1 in 1..N)(if D[ev1]=day /\ R[ev1]=room /\ M[ev1]<pos then Len[ev1] else 0 endif);
  }in
  
  (timebefore <= Break) /\ ( (timebefore + len) > Break)
);

predicate is_used(int : day, int : room) = exists(ev in 1..N)(D[ev]=day /\ R[ev]=room);

predicate is_last_day(var int : ev) = 
  not exists(ev1 in 1..N)( D[ev]=D[ev1] /\ R[ev]=R[ev1] /\ M[ev]<M[ev1]);
  
predicate continuity() =
forall(e in 1..N)(
  if M[e] > 1 then
    forall(pos in 1..(M[e]-1))(
      exists(e1 in 1..N)(D[e1]=D[e] /\ R[e1]=R[e] /\ M[e1] = pos)
    )
  else % M=1
    if R[e] > 1 then
      forall(room in 1..(R[e]-1))(
        exists(e2 in 1..N)(D[e2]=D[e] /\ R[e2]=room /\ M[e2]=1)
      )
    else % M=1 AND R=1
      if D[e] > 1 then
        exists(e3 in 1..N)(D[e3]=D[e]-1 /\ R[e3]=X /\ M[e3]=1)
      else % M=1 AND R=1 AND D=1
        not exists(e4 in 1..N where e4!=e)(D[e4]=1 /\ R[e4]=1 /\ M[e4]=1)
      endif
    endif
  endif
);
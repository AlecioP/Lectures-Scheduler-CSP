%%%%%%%%%%%%%%%%%%%%%%%%%-----UTIL-FUNCTIONS-----%%%%%%%%%%%%%%%%%%%%%%%%%

%Function to compute the start time of an event
function var int: start(var int: ev ) =(
  let {
    var int : day = D[ev];
    var int : room = R[ev];
    var int : len = Len[ev];
    var int : pos = M[ev];
    var int : timebefore =
      sum(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room /\ M[ev1]<pos)(Len[ev1]);
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
              var int : timebefore1 = sum(ev3 in 1..N where D[ev3]=day /\ R[ev3]=room /\ M[ev3]>=pos1 /\ M[ev3] < pos)(Len[ev3]);
            } in 
              (End + timebefore1)
        endif
    endif  
);

predicate is_first_afternoon(var int : ev) = (
    let {
    var int : day = D[ev];
    var int : room = R[ev];
    var int : len = Len[ev];
    var int : pos = M[ev];
    var int : timebefore =
      sum(ev1 in 1..N where D[ev1]=day /\ R[ev1]=room /\ M[ev1]<pos)(Len[ev1]);
  }in
  
  timebefore <= Break /\ timebefore + len > Break
);
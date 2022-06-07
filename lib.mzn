function var int : timebefore(var int : ev) = 
sum(ev1 in same_day_room(ev))( if M[ev1]<M[ev] then Len[ev1] else 0 endif);

function var int: start(int: ev ) =(let { var int : tb = timebefore(ev); }in
    if (tb + Len[ev]) <= Break
      then
        tb
      else
        if tb <= Break
          then
            End
          else
            let{
              % The index of the first event in the afternoon
              var int : index = sum(ev2 in same_day_room(ev))(
                if is_first_afternoon(ev2) then ev2 else 0 endif);
              var int : tb1 = sum(ev3 in same_day_room(ev))(if M[ev3]>=M[index] /\ M[ev3] < M[ev] then Len[ev3] else 0 endif);

            } in 
              (End + tb1)
        endif
    endif  
);

function var int : finish(int : ev) = start(ev)+Len[ev];

function var set of int : same_day_room(var int : ev) = {i | i in 1..N where D[i]=D[ev] /\ R[i]=R[ev]};

predicate is_first_afternoon(int : ev) = (let { var int : tb =timebefore(ev); }in
  (tb <= Break) /\ ( (tb + Len[ev]) > Break));

predicate is_last_day(int : ev) = 
  not exists(ev1 in same_day_room(ev))( M[ev]<M[ev1]);

predicate in_morning(int : e) = (start(e)<= Break);
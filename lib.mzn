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
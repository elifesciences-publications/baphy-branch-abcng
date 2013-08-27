

t=Torc;
t=set(t,'Duration',3);

% 4:4:48
t=set(t,'Rates','4:4:48');
t=set(t,'FrequencyRange','L:125-4000 Hz');
torc448Lparms=get(t);

t=set(t,'FrequencyRange','H:250-8000 Hz');
torc448Hparms=get(t);

t=set(t,'FrequencyRange','V:500-16000 Hz');
torc448Vparms=get(t);


% 8:8:48
t=set(t,'Rates','8:8:48');
t=set(t,'FrequencyRange','L:125-4000 Hz');
torc848Lparms=get(t);

t=set(t,'FrequencyRange','H:250-8000 Hz');
torc848Hparms=get(t);

t=set(t,'FrequencyRange','V:500-16000 Hz');
torc848Vparms=get(t);

% 4:4:24
t=set(t,'Rates','4:4:24');
t=set(t,'FrequencyRange','L:125-4000 Hz');
torc424Lparms=get(t);

t=set(t,'FrequencyRange','H:250-8000 Hz');
torc424Hparms=get(t);

t=set(t,'FrequencyRange','V:500-16000 Hz');
torc424Vparms=get(t);

save torc_parms torc424Hparms torc424Lparms torc424Vparms torc448Hparms ...
   torc448Lparms  torc448Vparms torc848Hparms torc848Lparms torc848Vparms
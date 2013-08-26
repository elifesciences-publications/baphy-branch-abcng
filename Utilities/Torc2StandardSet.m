t=Torc2;

freqrange={'L:125-4000 Hz','H:250-8000 Hz','V:500-16000 Hz',...
   'U:1000-32000 Hz','W:2000-64000 Hz','Y:1000-32000 Hz','Z:150-38400 Hz'};
raterange={'1:1:8','2:2:12','2:2:16','4:4:24','4:4:48','8:8:48','8:8:96'};
modrange=[0 30];

for ff=1:5,
   t=set(t,'FrequencyRange',freqrange{ff});
   for rr=[2 3 4 ],
      t=set(t,'Rates',raterange{rr});
      for mm=1:length(modrange),
         fprintf('%s %s %d\n',freqrange{ff},raterange{rr},modrange(mm));
         t=set(t,'ModDepth',modrange(mm));
      end
   end
end

%% user-defined parameter
trainingplace = 'BFG';
animalname = 'Mackenzie';
singleday = 1;

fromdate.year = 2011;
fromdate.month = 8;
fromdate.day = 3;

todate.year = 2011;
todate.month = 8;
todate.day = 3;


%%

current_year = fromdate.year;
current_month = fromdate.month;
current_day = fromdate.day;

summary1 = [];
firstfile = 1;

while current_year <= todate.year && current_month <= todate.month && current_day <= todate.day
    
    
    yearstr = num2str(current_year);
    monthstr = num2str(current_month);
    daystr = num2str(current_day);
    if length(monthstr) == 1
        monthstr = ['0',monthstr];
    end
    if length(daystr) == 1
        daystr = ['0',daystr];
    end
    
    trailnumber = 1;
    while 1
        fn = [animalname, '_',yearstr,'_',monthstr,'_',daystr,'_',trainingplace,'_',num2str(trailnumber),'.m'];
        [summary1_tmp, summary2_tmp, reffreqvec_tmp, reflengthvec_tmp,timevectmp,lickcelltmp,skipflag] = broadAttn_behav_ana(fn);
        if skipflag == 1
            break
        elseif skipflag == 2
            trailnumber = trailnumber + 1;
            continue
        end
        trailnumber = trailnumber + 1;
        if firstfile == 1
            summary1 = summary1_tmp;
            summary2 = summary2_tmp;
            reffreqvec = reffreqvec_tmp;
            reflengthvec = reflengthvec_tmp;
            timevec = timevectmp;
            lickcell = lickcelltmp;
            firstfile = 0;
        else
            summary1 = summary1 + summary1_tmp;
            summary2 = summary2 + summary2_tmp;
            for i = 1 : length(reffreqvec)
                for j = 1 : length(reflengthvec)
                    lickcell{(i - 1)*length(reflengthvec) + j} = [ lickcell{(i - 1)*length(reflengthvec) + j}, lickcelltmp{(i - 1)*length(reflengthvec) + j}];
                end
            end
        end
    end
    current_day = current_day + 1;
    if current_day == 29 && current_month  == 2
        if mod(current_year, 4) == 0
            continue
        else
            current_day = 1;
            current_month = 3;
        end
    end
    if current_day == 31 && (current_month == 4 || current_month == 6 || current_month == 9 || current_month == 11)
        current_day = 1;
        current_month = current_month + 1;
    end
    if current_day == 32 && (current_month == 1 || current_month == 3 || current_month == 5 || ...
            current_month == 7 || current_month == 8 || current_month == 10 || current_month == 12)
        current_day = 1;
        current_month = current_month + 1;
        if current_month == 13
            current_month = 1;
            current_year = current_year + 1;
        end
    end
end

if ~isempty(summary1)
    broadAttn_behav_draw(summary1, summary2, reffreqvec, reflengthvec,timevec,lickcell);
else
    disp('No valid file found!')
end





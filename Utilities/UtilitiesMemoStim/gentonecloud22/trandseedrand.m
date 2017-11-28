function stateseed=trandseedrand
%uses rand's seed to create a random seed for rand
%e.g., to get the same random numbers twice, then different random numbers:
% stateseed=trandseedrand; rand('seed',stateseed); rand(1,5), rand('seed',stateseed); rand(1,5), stateseed=trandseedrand; rand('seed',stateseed); rand(1,5), rand('seed',stateseed); rand(1,5),

stateseed=trand(2^31); %integer between 0 and 2^31

% %try out the seed, and check there's nothing too strange
% oldseed=randn('state');
% randn('state',stateseed)
% if any(stateseed~=randn('state'))
%     %stateseed-randn('state')
%     error('This doesn''t work how the programmer thought it did')
% end;
% randn('state',oldseed); %reset things to how they were
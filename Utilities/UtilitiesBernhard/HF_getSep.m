function Sep = HF_getSep;
if ~isempty(findstr('PCWIN64',computer)) Sep = '\'; else Sep = '/'; end

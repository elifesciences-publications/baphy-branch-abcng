function Hostname = HF_getHostname

switch computer
  case 'PCWIN64'; Hostname = getenv('COMPUTERNAME');
  otherwise [tmp,Hostname] = system('hostname'); Hostname = Hostname(1:end-1);
end
Pos = find(Hostname == '.');
if ~isempty(Pos) Hostname = Hostname(1:Pos-1); end

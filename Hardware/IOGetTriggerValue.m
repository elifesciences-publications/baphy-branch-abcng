function TrigVal = IOGetTriggerValue(Engine,Operation)

if strcmp(get(Engine,'TriggerType'),'HwDigital') % IF DIGITAL TRIGGERING IS DONE
  TriggerCondition = 'NegativeEdge';
  try TriggerCondition = get(Engine,'TriggerCondition'); end
  switch TriggerCondition
    case 'PositiveEdge'; TrigVal = 1;
    case 'NegativeEdge'; TrigVal = 0;
  end
end

switch upper(Operation)
  case 'RESET'; TrigVal = 1-TrigVal;
  case 'TRIGGER'; % NOTHING TO BE DONE
end
function HF_sendEmail(varargin)

P = parsePairs(varargin);
checkField(P,'From','nsl.umd@gmail.com');
checkField(P,'To','benglitz@gmail.com');
checkField(P,'Subject','Test');
checkField(P,'Body','Body');
checkField(P,'Username','nsl.umd');
checkField(P,'Password','feartheferret');

switch architecture
  case 'PCWIN';
    
    WinVersion = evalc('! ver');
    Pos = strfind(WinVersion,'[Version ');
    WinVersion = str2num(WinVersion(Pos+9:Pos+11));
    if WinVersion>=6
      NET.addAssembly('System.Net');
      import System.Net.Mail.*;
      mySmtpClient = SmtpClient('smtp.gmail.com');
      mySmtpClient.UseDefaultCredentials = false;
      mySmtpClient.Credentials = System.Net.NetworkCredential(P.Username,P.Password);
      mySmtpClient.EnableSsl = true;
      
      FromAddress = MailAddress(P.From);
      ToAddress = MailAddress(P.To);
      
      myMail = MailMessage(FromAddress, ToAddress);
      
      myMail.Subject = P.Subject;
      myMail.SubjectEncoding = System.Text.Encoding.UTF8;
      myMail.Body = '<b>Test Mail</b><br>using <b>HTML</b>';
      
      Body = '<b>Results : </b><br>';
      if iscell(P.Body)
        for i=1:length(P.Body) Body = [Body,'',P.Body{i},'<br>']; end;
      else Body = P.Body;
      end
      myMail.Body = Body;
      myMail.BodyEncoding = System.Text.Encoding.UTF8;
      myMail.IsBodyHtml = true;
      mySmtpClient.Send(myMail);
    else
      warning(['Sending emails not implemented below Windows 7']);
    end
    
  case 'UNIX'
    system(['Sender="',P.From,'"']);
    system(['Receiver="',P.To,'"']);
    system(['Body="',P.Body,'"']);
    system(['Subject="',P.Subject,'"']);
    
    system(['echo $Body  | mailx $Receiver -s $Subject']);
   
    
  otherwise
    warning(['Sending emails for system : ',computer,' not implemented']);
end
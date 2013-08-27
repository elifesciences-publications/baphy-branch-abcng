% oscilloscope 2 : testing background streaming.
global BAPHYHOME

%remap=[25 17 9 1 26 18 10 2 27 19 11 3 28 20 12 4 29 21 13 5 30 22 14 6 31 23 15 7 32 24 16 8]
remap=[8 16 7 15 6 14 5 13 4 12 3 11 2 10 1 9 [8 16 7 15 6 14 5 13 4 12 3 11 2 10 1 9]+16];
remap=[remap remap+32 remap+64];
bankremap=[1:3:96 2:3:96 3:3:96];
fullremap=bankremap(remap);

%close all;
figure(1);
drawnow;

Bstepsize=200;
Btotalsteps=100;
DSR=5000000;
ASR=round(DSR./1200);
bitspersample=16;
datafile='F:\data\HSDIO.bin';
debugfile='F:\data\DEBUG.txt';
%datafile='D:\HSDIO.bin';
%debugfile='D:\HSDIO.out';

streamcmd=[BAPHYHOME filesep 'Hardware' filesep 'hsdio' filesep '64-bit' filesep ...
  'hsdio_stream_dual ' datafile, ' ' num2str(DSR) ' ' num2str(Bstepsize),...
  ' ' num2str(Btotalsteps) ' D1 0 XX 96 ' num2str(bitspersample) ' 0 > ' debugfile]
%streamcmd=['D:\Code\baphy\Hardware\hsdio\hsdio_stream_dual D:\HSDIO.bin 33333333 ',num2str(Bstepsize),' ',num2str(Btotalsteps),...
%  ' D10  0  96  16  0    >  D:\HSDIO.out']
[status,result] = system(['start /b ',streamcmd]);
Bframestop=Bstepsize*Btotalsteps;

pause(0.05);
NumberOfChannels=96;
Bsamp=2000;
tt=(1:Bsamp)./ASR;
Bfull=zeros(Bsamp,NumberOfChannels);
Aresidual=[];

plot_channels=1:8;

fclose all

jfile = java.io.File(datafile);
lastflen=0;
datacount=0;
fin=fopen(datafile,'r');
Bframes=0;
while Bframes<Bframestop-1,
  newflen=length(jfile);
  
  % only read data if file length has changed
  if newflen>lastflen,
    lastflen=newflen;
    AData=[Aresidual;fread(fin,'uint16')];
    datacount=datacount+length(AData);
    completeframes=floor(length(AData)./NumberOfChannels).*NumberOfChannels;
    A=reshape(double(AData(1:completeframes)),NumberOfChannels,...
      completeframes./NumberOfChannels)';
    Aresidual=AData((completeframes+1):end);
    
    if length(A)>0,
      B=A(:,fullremap);
      if bitspersample==16,
        B=B-2.^15;
        sf=24000;
      else
        sf=3000;  % normalize by sf before plotting
      end
      %B=permute(B,[1 3 2]);
      %B=B(:,remap,:);
      %B=B(:,:);
      Bframes=Bframes+size(B,1);
      if size(B,1)>Bsamp,
        disp('B overload');
        Bfull=B((end-Bsamp+1):end,:);
      else
        Bfull=[Bfull((size(B,1)):end,:);B(1:(end-1),:)];
      end
      
      sfigure(1);
      if isempty(plot_channels) || length(plot_channels)==96,
        subplot(1,3,1);
        for ii=1:32,
          plot(Bfull(:,ii)./sf+ii);
          hold on
          plot([1 size(Bfull,1)],[ii ii],'k--')
        end
        hold off
        title('1-32');
        
        subplot(1,3,2);
        for ii=1:32,
          plot(Bfull(:,ii+32)./sf+ii);
          hold on
          plot([1 size(Bfull,1)],[ii ii],'k--')
        end
        hold off
        title('33-64');
        
        subplot(1,3,3);
        for ii=1:32,
          plot(Bfull(:,ii+64)./sf+ii);
          hold on
          plot([1 size(Bfull,1)],[ii ii],'k--')
        end
        hold off
        title('65-96');
      else
        clf
        
        for ii=1:length(plot_channels),
          plot(tt,Bfull(:,plot_channels(ii))./sf+ii);
          hold on
          plot(tt([1 end]),[ii ii],'k--');
        end
      end
      drawnow;
      [length(AData) size(B,1) Bframes]
    end
   
  end
end

disp('read expected number of frames');
fclose(fin);

return

c1=6;c2=10;
bset=zeros(Bsamp,12,2);
s=Bfull(:,[c1 c2])+2047;
s(:,3)=round(sign(sin(2.*pi.*100.*tt)).*500)+2047;
for b=1:12,
  for c=1:3,
    bset(:,b,c)=bitand(s(:,c),2.^(b-1));
  end
end
figure(2);
clf
for c=1:3,
  subplot(3,1,c);
  for ii=1:12,
    plot(tt(1:500),bset(1:500,ii,c)./max(1,max(bset(:,ii,c))).*0.75+ii);
    hold on
  end
  %plot(tt([1 end]),[ii ii],'k--');
end



function  [yo,pho,mi,mo,mvec] = phsopt(ami,rvi,rfi,phi,niter,step,T,saf,PLOT);
%
%[yo,pho,mi,mo,mvec] = phsopt(ami,rvi,rfi,phi,niter,step,T,saf,PLOT);
%Example: [yo,pho,mi,mo,mvec] = phsopt(a1am{1}',a1rv{1}',a1rf{1}',a1ph{1}',500,1,250,1000);

if nargin < 9, PLOT = 1; end 

SHOW = 10;
mvec = zeros(1,niter);
l = length(rvi);
pho = phi;

% Initial stimulus construction
[waveParams,W,Omega] = makewaveparams({ami'},{rfi'},{phi'},{rvi'});
[y,freqs] = ststruct(waveParams,W,Omega,125,4000,100,T,saf);
	
mi = max(max(abs(y)));  % Initial maximum absolute value
mvec(1) = mi;

if PLOT,
   figure(66), hold off
   plot(1,mi,'*'), hold on
   figure(67), hold off
   subplot(221), imagesc(y,[-mi,mi])
end
	

for iter = 2:niter,
		
   purt = round(rand(l,1))*step - step/2;   % Purturbation vector
   % New stimulus construction
   [waveParams,W,Omega] = makewaveparams({ami'},{rfi'},{(phi+purt)'},{rvi'});
   [ytry,freqs] = ststruct(waveParams,W,Omega,125,4000,100,T,saf);	

   mvec(iter) = max(max(abs(ytry)));
   if PLOT,
      if ~mod(iter,SHOW)
       figure(66)
       plot(1:iter,mvec(1:iter),'x'),
      end 
   end

   % If maximum absolute value decreases, keep new phases
   if mvec(iter) < max(max(abs(y))),
      phi = phi + purt;
      y = ytry;
      pho = phi;
   end

end
grid
yo = y;
mo = max(max(abs(yo)));
  
figure(67), subplot(222), imagesc(yo)
 

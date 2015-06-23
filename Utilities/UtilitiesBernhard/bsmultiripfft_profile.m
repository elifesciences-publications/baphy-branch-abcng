%bsmultiripfft(SamplingRate, Rips)
%   Creates one second of a sum of ripples waveform composed of the ripples
%   specified in Rips.  The sampling rate of the waveform generated is
%   passed in SamplingRate.  Only component frequencies that are multiples
%   of 1Hz are used.  This should be noted when specifying the number of
%   components per octave (explained below).  Rips is an Nx10 matrix.  Each
%   row corresponds to one component ripple and each column, one of its
%   parameters as follows:
%   
%   [Am, Om, w, ph, baseF, BW, dF, dA, linflag, ro]
%       Am - Amplitude 
%       Om - Spectral density (cyc/oct)
%       w - Velocity/modulation frequency (Hz)
%       ph - Modulation phase at the base frequency (rads) (0 = cosine)
%       baseF - Base frequency (Hz)
%       BW - Bandwidth (octaves)
%       dF - Component spacing (octaves)
%       dA - Modulation depth - in percent if linear, or dB if log
%       linflag - 1 if modulation is to be linear, 0 if log
%       ro - Roll off per octave.  -3 for half power with increasing x
%       
%   Since the frequencies are all integer multiples of 1Hz, the 
%   spacing is not exactly dF.  In practice, the frequencies are rounded to
%   the nearest Hz.  If spacing is too dense, some frequencies in the lower
%   ranges might be rounded to the same value and thus be merged into one
%   component.  This would generate a ripple with slightly less power in
%   the lower band.  To avoid such complications, this inequality must be 
%   true:
%
%       length(unique(round(baseF.*2.^(0:dF:BW)))) ~= length(0:dF:BW)
%
%   Carrier frequencies are phase randomized, but in a consistent manner.
%   The seed of the randomizer is reset to 613 each time bsmultiripfft is
%   called by executing the line: 
%
%       rand('state',613);
%
%   Created by: Barak Shechter on Nov. 22, 2005
function s = bsmultiripfft_profile(SamplingRate,Rips,ExpandLinProfileForLog)
    %Make sure sampling rate is even
    init_rand_state = rand('state');
    rand('state',613);
    if nargin<3
        ExpandLinProfileForLog = 0;
    end
    
%    [Am Om w ph baseF bw df dA linflag];
    sr = floor(SamplingRate);
    S = fftshift([1 zeros(1,sr-1)]); 
    %Index of the DC component of the FFT of the waveform to be generated.
    %Each value less that iDC is the -Nth harmonic of the waveform and each
    %value greater than iDC is the +Nth harmonic, where N = abs(iDC-iN)
    iDC = find(S==1);  S(iDC) = 0;

    dx = min(Rips(:,7));
    fMin = min(Rips(:,5));
    fMax = max(Rips(:,5).*2.^(Rips(:,6)));
    BW = log2(fMax./fMin);
    S = zeros(ceil(BW/dx)+1,SamplingRate);
    
    %highest term pascal coefficients in the cos^n(x) expansions
    %They are derived by:
    % coefs = pascal(11)
    % for k = 1:10
    % cf(k*2-1) = coefs(k+1,k); cf(k*2) = coefs(k+1,k+1);
    % end
    % cf./2.^(1:20);
    %    cf =  [0.5000    0.5000    0.3750    0.3750    0.3125    0.3125    0.2734    0.2734    0.2461    0.2461 ...
    %          0.2256    0.2256    0.2095    0.2095    0.1964    0.1964    0.1855    0.1855    0.1762    0.1762 ] ;
    %    dbcoef = 1 ./ factorial(1:20) ./ 20.^(1:20);
    
    %Pascal matrix used to compute the coefficients for the analytic
    %expansion of 10^[dA*sin(Om*x+w*t+ph)/20]
    pasc = pascal(20);
    for k = 1:20
        dbcoef{k} = diag(pasc,k-1)';
    end
%        cPh= rand(1,length(freqs))*2*pi;
%    allPh = rand(1,SamplingRate)*2*pi;
    if Rips(1,9) == 1 %Linear Profile
    for k = 1:size(Rips,1)
        %Extract ripple params
        Am = Rips(k,1); Om = Rips(k,2); w = Rips(k,3);
        ph = Rips(k,4); baseF = Rips(k,5); bw = Rips(k,6);
        df = Rips(k,7); dA = Rips(k,8);  linflag = Rips(k,9);
        if size(Rips,2) >= 10
            ro = Rips(k,10);
        else
            ro = 0;
        end
        
        %Compute which component frequencies to use and their distance from
        %the base in octaves
        %Make sure baseF is a multiple of dx octaves away from fMin.  In
        %the case that all the baseFs are the same, nothing will change
        baseF = fMin.*2.^(round(log2(baseF/fMin)/dx)*dx);
    
        freqs = unique(baseF.*2.^(0:dx:bw));
        if length(freqs)~=length(0:df:bw)
            disp('Frequency spacing is too dense.  Some frequencies are being overridden');
        end
        xF = log2(freqs/baseF);
        iF = round(log2( baseF/fMin.*2.^(0:dx:bw))/dx);
        
        %Starting phase of the modulation at each frequency component
        ripPh = 2*pi*Om*xF+ph;
        
        %Random component phases
%        cPh = allPh(freqs);
        
        %Indices to each of the frequency components in the fft and the
        %w - the modulation rate which is also the distance between the
        %carrier and its sidebands and between each adjacent sideband in
        %the case of log modulation
        %iF = [-freqs freqs] + iDC;
%        w = w.*[ones(length(iF),1)]; % ones(1,length(freqs))];
    
        
        %Linear Modulation
        %The carrier has a random phase and the two sidebands with
        %amplitude at half the modulation and phase relative to the
        %carrier's
        if linflag==1
%            S(iF) = S(iF) + Am.*exp(i*[-cPh cPh]);
            S(iF+1,iDC) = S(iF+1,iDC) + Am*2;
            S(iF+1,iDC + [-w w]) = S(iF+1,iDC+[-w w]) + 2*Am.*dA/2*exp([-i*ripPh' i*ripPh']);
%            S(iF+1,iDC+w) = S(iF+1,iDC+w) + Am.*dA/2*exp(i*ripPh');
        else
        %Log Modulation
            %First lets decide how accurate we want to be
%        Acoef = dbcoef .*dA.^(1:20);
%        nterms = max(find((cf.*Acoef./(cf*Acoef'))>5e-5));
%        for term = 1:nterms
        %We will compute N sidebands.  The expansion can be worked out
        %analytically as:
        %
        % e^(Acos(wt)) = 1 + Acos(wt) + (Acos(wt))^2/2! + ... + (Acos(wt))^N/N!
        %
        % and cos(wt)^N can be worked out by [(e^iwt + e^-iwt)/2]^N
        %
            N = 20;
            dA = dA.*log(10);
            %S(iF) = S(iF) + Am.*exp(i*[-cPh cPh]) * sum( (dA/40).^(0:2:N).*dbcoef{1}(1:N/2+1)./factorial(0:2:N) );
            S(iF+1,iDC) = S(iF+1,iDC) + 2*Am.*sum( (dA/40).^(0:2:N).*dbcoef{1}(1:N/2+1)./factorial(0:2:N) );
            for l = 1:19
                if w*l <= SamplingRate-iDC
                    S(iF+1,iDC+l.*[-w w]) = S(iF+1,iDC+l.*[-w w]) + 2*Am.*exp(i*l*[-ripPh' ripPh'])*sum( (dA/40).^(l:2:N).*dbcoef{l+1}(1:(floor((N-l)/2)+1))./factorial(l:2:N) );
%                    S(iF,+l*w) = S(iF+l*w) + Am.*exp(i*[-(cPh+l*ripPh) cPh+l*ripPh])*sum( (dA/40).^(l:2:N).*dbcoef{l+1}(1:(floor((N-l)/2)+1))./factorial(l:2:N) );
                end
            end
            
        end
    end
        s = real(ifft(ifftshift(S,2),[],2));
    else %log Profile
        nRips = size(Rips,1);
        proRips = Rips;
        proRips(:,1) = Rips(:,8)/20/2;%ones(nRips,1);
        proRips(:,8) = ones(nRips,1);
        proRips(:,9) = ones(nRips,1);
        proRips(:,10) = zeros(nRips,1);
        
%        nSigHarmonics = 20.*max(Rips(:,3));
%        dx = min(Rips(:,7));
%        fMin = min(Rips(:,5));
%        fMax = max(Rips(:,5).*2.^(Rips(:,6)));
%        BW = log2(fMax./fMin);
        
        pro = bsmultiripfft_profile(SamplingRate,proRips)*SamplingRate;
%        tmp = 10.^(pro(:,1:ceil(size(pro,2)/4))-mean(pro(:)));
%        figure,imagesc(tmp); title(num2str(20*log10(max(tmp(:))/min(tmp(:)))))
        if ExpandLinProfileForLog == 1
            a = (max(abs(pro(:))) - mean(pro(:))) / mean(pro(:)); %We want 100% modulation on the linear envelope so that we have exactly dA dB modulation
            proRips(:,8) = proRips(:,8)./a;
            pro = bsmultiripfft_profile(SamplingRate,proRips)*SamplingRate;            
        end
        s = 2*sum(Rips(:,1)).*10.^(pro-mean(pro(:)))/SamplingRate;

        
    end
    rand('state',init_rand_state);
    %    s = (ifft(ifftshift(S)));
    %s = s/max(s);
    %s = repmat(s,1,ceil(T));
    %s = s(1:floor(SamplingRate*T));
return

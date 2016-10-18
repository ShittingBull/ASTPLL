function [pitch] = trackPitch(x, bufferSize, fCenter, filterFCenter,Kd, Fs, resetFlag)
% shiftPitch This function is used in audioPitchShifterExample

%  Copyright 2015 The MathWorks, Inc.

%#codegen
pitch = zeros(bufferSize,8);
persistent pllTracker1 pllTracker2 pllTracker3 pllTracker4 pllTracker5 pllTracker6 pllTracker7 pllTracker8;
persistent envDet1 envDet2 envDet3 envDet4 a b;
persistent filter1 filter2 filter3 filter4 numFilters numSoS;
numFilters = 4;
%a = zeros(numFilters, numSoS * 2+1);
%b = zeros(numFilters, numSoS * 2+1);
numFilters = 4;
numSoS = 4;
filterFCenter_ = [80.0600000000000 160.120000000000 160.120000000000 320.240000000000 320.240000000000 640.480000000000 640.480000000000 1280.96000000000];
b1 = [0.000105057935033459 -0.000809483335833669 0.00275706294517459 -0.00542382819219676 0.00674238129567412 -0.00542382819219676 0.00275706294517459 -0.000809483335833667 0.000105057935033459];
b2 = [0.000124725246063662 -0.000869614924024176 0.00274388685020676 -0.00514458410136750 0.00629117386557294 -0.00514458410136750 0.00274388685020677 -0.000869614924024178 0.000124725246063662];
b3 = [0.000214520545468546 -0.00111887724410578 0.00274063964723915 -0.00432298800504123 0.00497341188369177 -0.00432298800504123 0.00274063964723915 -0.00111887724410578 0.000214520545468546];
b4 = [0.000710491766423473 -0.00192208288216881 0.00202097897644363 -0.00203851092999457 0.00245863810326683 -0.00203851092999457 0.00202097897644363 -0.00192208288216881 0.000710491766423475];
a1 = [1 -7.93796149810862 27.5860241756024 -54.8180930140147 68.1288897771271 -54.2264565333318 26.9937902498322 -7.68371950072066 0.957526343907712];
a2 = [1 -7.83916991862188 26.9586061577262 -53.1202104912837 65.5951605922722 -51.9795708813182 25.8133525468962 -7.34502920268381 0.916861270317286];
a3 = [1 -7.53510081647868 25.1185707129923 -48.3718449626600 58.8493655248098 -46.3154581436169 23.0287184345855 -6.61490104758397 0.840668006083466];
a4 = [1 -6.53597426427747 19.6457677624655 -35.2906062704409 41.3545144391363 -32.3493770725518 16.5085690229687 -5.03591862682645 0.706944656268470];


if isempty(pllTracker1)
    
    %[b(i,:), a(i,:)] = ellip(3, 1, 100, [80 160]) 
    %[b1, a1] = ellip(3, 1, 100, [(filterFCenter_(1)/(44100/2)) (filterFCenter_(2) /(44100/2))]); 
    %[b(2,:), a(2,:)] = ellip(3, 1, 100, [(filterFCenter_(3)/(44100/2)) (filterFCenter_(4) /(44100/2))]); 
    %[b(3,:), a(3,:)] = ellip(3, 1, 100, [(filterFCenter_(5)/(44100/2)) (filterFCenter_(6) /(44100/2))]); 
    %[b(4,:), a(4,:)] = ellip(3, 1, 100, [(filterFCenter_(7)/(44100/2)) (filterFCenter_(8) /(44100/2))]); 
    filter1 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator', b1, 'Denominator', a1);
    filter2 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator', b2, 'Denominator', a2);
    filter3 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator', b3, 'Denominator', a3);
    filter4 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator', b4, 'Denominator', a4);
    envDet1 = EnvDetector;
    pllTracker1 = PLLClass(fCenter(1),Kd(1),Fs);
    setSampleRate(pllTracker1,Fs);
    pllTracker2 = PLLClass(fCenter(2),Kd(2),Fs);
    setSampleRate(pllTracker2,Fs);
    envDet2 = EnvDetector;
    pllTracker3 = PLLClass(fCenter(3),Kd(3),Fs);
    setSampleRate(pllTracker3,Fs);
    pllTracker4 = PLLClass(fCenter(4),Kd(4),Fs);
    setSampleRate(pllTracker4,Fs);
    envDet3 = EnvDetector;
    pllTracker5 = PLLClass(fCenter(5),Kd(5),Fs);
    setSampleRate(pllTracker5,Fs);
    pllTracker6 = PLLClass(fCenter(6),Kd(6),Fs);
    setSampleRate(pllTracker6,Fs);
    envDet4 = EnvDetector;
    pllTracker7 = PLLClass(fCenter(7),Kd(7),Fs);
    setSampleRate(pllTracker7,Fs);
    pllTracker8 = PLLClass(fCenter(8),Kd(8),Fs);
    setSampleRate(pllTracker8,Fs);
    
end


if nargin < 7
    resetFlag = false;
end
if ~isempty(pllTracker1)
    if resetFlag
        reset(pllTracker1);
        reset(pllTracker2);
        reset(pllTracker3);
        reset(pllTracker4);
        reset(pllTracker5);
        reset(pllTracker6);
        reset(pllTracker7);
        reset(pllTracker8);
        return;
    end
    
    x1 = step(filter1, x);
    x1 = step(envDet1,x1);
    
    pllTracker1.fCenter = fCenter(1);
    pllTracker1.Kd    = Kd(1);
    pitch(:,1) = step(pllTracker1,x1);
    
    pllTracker2.fCenter = fCenter(2);
    pllTracker2.Kd    = Kd(2);
    pitch(:,2) = step(pllTracker2,x1);
    
    
    
    x2 = step(filter2, x);
    x2 = step(envDet2,x2);
    
    pllTracker3.fCenter = fCenter(3);
    pllTracker3.Kd    = Kd(3);
    pitch(:,3) = step(pllTracker3,x2);
    
    pllTracker4.fCenter = fCenter(4);
    pllTracker4.Kd    = Kd(4);
    pitch(:,4) = step(pllTracker4,x2);
    
    
    
    x3 = step(filter3, x);
    x3 = step(envDet3,x3);
    
    pllTracker5.fCenter = fCenter(5);
    pllTracker5.Kd    = Kd(5);
    pitch(:,5) = step(pllTracker5,x3);
    
    pllTracker6.fCenter = fCenter(6);
    pllTracker6.Kd    = Kd(6);
    pitch(:,6) = step(pllTracker6,x3);
    
    
    x4 = step(filter4, x);
    x4 = step(envDet4,x4);
    
    pllTracker7.fCenter = fCenter(7);
    pllTracker7.Kd    = Kd(7);
    pitch(:,7) = step(pllTracker7,x4);
    
    pllTracker8.fCenter = fCenter(8);
    pllTracker8.Kd    = Kd(8);
    pitch(:,8) = step(pllTracker8,x4);
    
end

% if ~isempty(pllTracker)
%     for i = 1 : 8
%         if isa(pllTracker{i},'PLLClass')
%             pllTracker{i}.fCenter = fCenter(i);
%             pllTracker{i}.Kd    = Kd(i);
%             pitch(i,:) = step(pllTracker{i},x);
%         end
%     end
% end
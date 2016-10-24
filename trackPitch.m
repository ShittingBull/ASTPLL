function [pitch] = trackPitch(x, bufferSize, fCenter, filterFCenter,Kd, Fs, resetFlag)
% shiftPitch This function is used in audioPitchShifterExample

%  Copyright 2015 The MathWorks, Inc.

%#codegen
pitch = zeros(bufferSize,8);
persistent pllTracker1 pllTracker2 pllTracker3 pllTracker4 pllTracker5 pllTracker6 pllTracker7 pllTracker8;
persistent envDet1 envDet2 envDet3 envDet4 a b;
persistent filter1 filter2 filter3 filter4 numFilters numSoS;
persistent fHP1 fHP2 fHP3 fHP4 fHP5 fHP6 fHP7 fHP8;
numFilters = 4;
%a = zeros(numFilters, numSoS * 2+1);
%b = zeros(numFilters, numSoS * 2+1);
numFilters = 4;
numSoS = 4;
filterFCenter_ = [80.0600000000000 160.120000000000 160.120000000000 320.240000000000 320.240000000000 640.480000000000 640.480000000000 1280.96000000000];
b1 = [0.00100282823742832 -0.00793462290001029 0.0275525472915120 -0.0548438333482487 0.0684461614389332 -0.0548438333482487 0.0275525472915119 -0.00793462290001027 0.00100282823742832];
b2 = [0.00103991559498592 -0.00796693001296241 0.0270249495074909 -0.0530359819587393 0.0658760938128036 -0.0530359819587393 0.0270249495074908 -0.00796693001296239 0.00103991559498592];
b3 = [0.00121727625977686 -0.00828402601803919 0.0256958911225454 -0.0476978605480339 0.0581374565843181 -0.0476978605480338 0.0256958911225454 -0.00828402601803918 0.00121727625977686];
b4 = [0.00203377831799350 -0.00949778393960610 0.0214203083384978 -0.0323966825192715 0.0368849057383270 -0.0323966825192715 0.0214203083384978 -0.00949778393960611 0.00203377831799350];
a1 = [1 -7.95214079465371 27.6846530625388 -55.1123063739565 68.6167933287457 -54.7122403418692 27.2841858794475 -7.78022498789049 0.971280227933667];
a2 = [1 -7.86722028055696 27.1518654977360 -53.6923531710000 66.5386453122635 -52.9155335325543 26.3719258500798 -7.53071696109162 0.943387359477195];
a3 = [1 -7.58913806513934 25.4803484246814 -49.4207747292700 60.5566160460859 -48.0002061908360 24.0368315053349 -6.95365414855227 0.889995374511900];
a4 = [1 -6.62967670547219 20.2163859673110 -36.8424464481725 43.7967799376830 -34.7518917795345 17.9877103207949 -5.56491798581183 0.792202826756546];
bHp = [0.0110759647918990 0.0110759647918990];
aHp = [1 -0.977848070416202]

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
    fHP1 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP2 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP3 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP4 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP5 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP6 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP7 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    fHP8 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bHp , 'Denominator', aHp);
    
    
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
    pitch(:,1) = step(fHP1,pitch(:,1));
    pllTracker2.fCenter = fCenter(2);
    pllTracker2.Kd    = Kd(2);
    pitch(:,2) = step(pllTracker2,x1);
    pitch(:,2) = step(fHP2,pitch(:,2));
    
    
    x2 = step(filter2, x);
    x2 = step(envDet2,x2);
    
    pllTracker3.fCenter = fCenter(3);
    pllTracker3.Kd    = Kd(3);
    pitch(:,3) = step(pllTracker3,x2);
    pitch(:,3) = step(fHP3,pitch(:,3));
    
    pllTracker4.fCenter = fCenter(4);
    pllTracker4.Kd    = Kd(4);
    pitch(:,4) = step(pllTracker4,x2);
    pitch(:,4) = step(fHP4,pitch(:,4));
    
    
    x3 = step(filter3, x);
    x3 = step(envDet3,x3);
    
    pllTracker5.fCenter = fCenter(5);
    pllTracker5.Kd    = Kd(5);
    pitch(:,5) = step(pllTracker5,x3);
    pitch(:,5) = step(fHP5,pitch(:,5));
    
    pllTracker6.fCenter = fCenter(6);
    pllTracker6.Kd    = Kd(6);
    pitch(:,6) = step(pllTracker6,x3);
    pitch(:,6) = step(fHP6,pitch(:,6));
    
    x4 = step(filter4, x);
    x4 = step(envDet4,x4);
    
    pllTracker7.fCenter = fCenter(7);
    pllTracker7.Kd    = Kd(7);
    pitch(:,7) = step(pllTracker7,x4);
    pitch(:,7) = step(fHP7,pitch(:,7));
     
    pllTracker8.fCenter = fCenter(8);
    pllTracker8.Kd    = Kd(8);
    pitch(:,8) = step(pllTracker8,x4);
    pitch(:,8) = step(fHP8,pitch(:,8));
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
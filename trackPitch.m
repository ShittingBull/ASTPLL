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
b1 = [0.000105085838397327 -0.000809564423336102 0.00275700339396659 -0.00542330664647146 0.00674156367491720 -0.00542330664647146 0.00275700339396659 -0.000809564423336103 0.000105085838397327];
b2 = [0.000124849484825569 -0.000869995974330180 0.00274387522264092 -0.00514309551069602 0.00628873356258332 -0.00514309551069602 0.00274387522264092 -0.000869995974330181 0.000124849484825569];
b3 = [0.000215109561128731 -0.00112034084816861 0.00274048033891141 -0.00431857558337306 0.00496665486575442 -0.00431857558337307 0.00274048033891141 -0.00112034084816861 0.000215109561128732];
b4 = [0.000714142195025890 -0.00192602627138661 0.00201284122956358 -0.00202737012456471 0.00245322479118226 -0.00202737012456472 0.00201284122956358 -0.00192602627138661 0.000714142195025890];
a1 = [1 -7.93777833111813 27.5848359715593 -54.8148038507096 68.1238574190435 -54.2218654555637 26.9912960905857 -7.68297374432783 0.957431900829725];
a2 = [1 -7.83863827163038 26.9552854314665 -53.1113811581270 65.5822382205566 -51.9683660805862 25.8076256631444 -7.34344417625731 0.916680446072226];
a3 = [1 -7.53340463886959 25.1085812228565 -48.3466826796439 58.8144186356759 -46.2867878464870 23.0150101155113 -6.61145345323898 0.840336671709228];
a4 = [1 -6.53035177942982 19.6171555151330 -35.2255922528519 41.2703788038587 -32.2833849759245 16.4779930691891 -5.02859890166647 0.706389006276954];
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
function [pitch] = trackPitch(x, bufferSize, fCenter, filterFCenter,Kd, Fs, resetFlag)
% shiftPitch This function is used in audioPitchShifterExample

%  Copyright 2015 The MathWorks, Inc.

%#codegen
pitch = zeros(bufferSize,8);
persistent pllTracker1 pllTracker2 pllTracker3 pllTracker4 pllTracker5 pllTracker6 pllTracker7 pllTracker8;
persistent envDet1 envDet2 envDet3 envDet4 a b;
persistent filter1 filter2 filter3 filter4 filter5 filter6 filter7 filter8 numFilters numSoS;
persistent fHP1 fHP2 fHP3 fHP4 fHP5 fHP6 fHP7 fHP8;
numFilters = 4;
%a = zeros(numFilters, numSoS * 2+1);
%b = zeros(numFilters, numSoS * 2+1);
numFilters = 4;
numSoS = 4;
filterFCenter_ = [80.0600000000000 160.120000000000 160.120000000000 320.240000000000 320.240000000000 640.480000000000 640.480000000000 1280.96000000000];
b1 = [0.000108577708705801 -0.000819961607043458 0.00275142494075665 -0.00536328664184797 0.00664649119903196 -0.00536328664184797 0.00275142494075665 -0.000819961607043457 0.000108577708705801];
b2 = [0.000140396827189275 -0.000917009014431126 0.00274413294236868 -0.00496967580300020 0.00600431013884976 -0.00496967580300019 0.00274413294236868 -0.000917009014431126 0.000140396827189275];
b3 = [0.000291184899919921 -0.00129401980930076 0.00270072647817739 -0.00380824205731172 0.00422071119261418 -0.00380824205731172 0.00270072647817738 -0.00129401980930075 0.000291184899919920];
b4 = [0.00121811534422936 -0.00233462623340905 0.000692534331913018 -0.000838263480842863 0.00252662040343563 -0.000838263480842861 0.000692534331913017 -0.00233462623340905 0.00121811534422937];
a1 = [1 -7.91667676354819 27.4487328292070 -54.4403836080771 67.5549449600875 -53.7069021740514 26.7140937655486 -7.60100241783457 0.947193410408045];
a2 = [1 -7.77626751398240 26.5687745122113 -52.0918015093737 64.1023915166688 -50.6971977288624 25.1653466497501 -7.16842958277734 0.897184087395995];
a3 = [1 -7.33210471682983 23.9413538304971 -45.4428472380410 54.8218679481891 -43.0399744346667 21.4771160668729 -6.23031093089821 0.805001630715167];
a4 = [1 -5.86570987064921 16.4000193694953 -28.1288222825564 32.2370922205985 -25.2298762853053 13.1936641853327 -4.23338583918038 0.648421774427983];
bLp = [0.0110759647918990 0.0110759647918990];
aLp = [1 -0.977848070416202]

if isempty(pllTracker1)
    
    %[b(i,:), a(i,:)] = ellip(3, 1, 100, [80 160]) 
    %[b1, a1] = ellip(3, 1, 100, [(filterFCenter_(1)/(44100/2)) (filterFCenter_(2) /(44100/2))]); 
    %[b(2,:), a(2,:)] = ellip(3, 1, 100, [(filterFCenter_(3)/(44100/2)) (filterFCenter_(4) /(44100/2))]); 
    %[b(3,:), a(3,:)] = ellip(3, 1, 100, [(filterFCenter_(5)/(44100/2)) (filterFCenter_(6) /(44100/2))]); 
    %[b(4,:), a(4,:)] = ellip(3, 1, 100, [(filterFCenter_(7)/(44100/2)) (filterFCenter_(8) /(44100/2))]); 
    filter1 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b1, 'Denominator', a1);
    filter2 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b2, 'Denominator', a2);
    filter3 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b3, 'Denominator', a3);
    filter4 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b4, 'Denominator', a4);
    filter5 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b1, 'Denominator', a1);
    filter6 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b2, 'Denominator', a2);
    filter7 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b3, 'Denominator', a3);
    filter8 = dsp.IIRFilter('Structure', 'Direct form I', 'Numerator', b4, 'Denominator', a4);
    fHP1 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP2 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP3 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP4 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP5 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP6 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP7 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fHP8 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    
    
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
    x1 = step(filter5, x1);
    x1 = step(envDet1,x1);
    
    pllTracker1.fCenter = fCenter(1);
    pllTracker1.Kd    = Kd(1);
    pitch(:,1) = step(pllTracker1,x1);
    %pitch(:,1) = step(fHP1,pitch(:,1));
    pllTracker2.fCenter = fCenter(2);
    pllTracker2.Kd    = Kd(2);
    pitch(:,2) = step(pllTracker2,x1);
    %pitch(:,2) = step(fHP2,pitch(:,2));
    
    
    x2 = step(filter2, x);
    x2 = step(filter6, x2);
    x2 = step(envDet2,x2);
    
    pllTracker3.fCenter = fCenter(3);
    pllTracker3.Kd    = Kd(3);
    pitch(:,3) = step(pllTracker3,x2);
    %pitch(:,3) = step(fHP3,pitch(:,3));
    
    pllTracker4.fCenter = fCenter(4);
    pllTracker4.Kd    = Kd(4);
    pitch(:,4) = step(pllTracker4,x2);
    %pitch(:,4) = step(fHP4,pitch(:,4));
    
    
    x3 = step(filter3, x);
    x3 = step(filter7, x3);
    x3 = step(envDet3,x3);
    
    pllTracker5.fCenter = fCenter(5);
    pllTracker5.Kd    = Kd(5);
    pitch(:,5) = step(pllTracker5,x3);
    %pitch(:,5) = step(fHP5,pitch(:,5));
    
    pllTracker6.fCenter = fCenter(6);
    pllTracker6.Kd    = Kd(6);
    pitch(:,6) = step(pllTracker6,x3);
    %pitch(:,6) = step(fHP6,pitch(:,6));
    
    x4 = step(filter4, x);
    x4 = step(filter8, x4);
    x4 = step(envDet4,x4);
    
    pllTracker7.fCenter = fCenter(7);
    pllTracker7.Kd    = Kd(7);
    pitch(:,7) = step(pllTracker7,x4);
    %pitch(:,7) = step(fHP7,pitch(:,7));
     
    pllTracker8.fCenter = fCenter(8);
    pllTracker8.Kd    = Kd(8);
    pitch(:,8) = step(pllTracker8,x4);
    %pitch(:,8) = step(fHP8,pitch(:,8));
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
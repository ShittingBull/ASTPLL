function [pitch] = trackPitch(x, bufferSize, fCenter, filterFCenter,Kd, Fs, resetFlag, stopFlag)
% shiftPitch This function is used in audioPitchShifterExample

%  Copyright 2015 The MathWorks, Inc.

%#codegen
pitch = zeros(bufferSize,8);
persistent pllTracker1 pllTracker2 pllTracker3 pllTracker4 pllTracker5 pllTracker6 pllTracker7 pllTracker8;
persistent envDet1 envDet2 envDet3 envDet4 a b;
persistent filterHP1 filterHP2 filterHP3 filterHP4 filterLP1 filterLP2 filterLP3 filterLP4 numFilters numSoS;
persistent fLP1 fLP2 fLP3 fLP4 fLP5 fLP6 fLP7 fLP8 SRC1 SRC2 SRC3 SRC4 PLLFs envDet5 envDet6;
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
aLp = [1 -0.977848070416202];
PLLFs = Fs;
if isempty(pllTracker1)
    
    %[b(i,:), a(i,:)] = ellip(3, 1, 100, [80 160]) 
    %[b1, a1] = ellip(3, 1, 100, [(filterFCenter_(1)/(44100/2)) (filterFCenter_(2) /(44100/2))]); 
    %[b(2,:), a(2,:)] = ellip(3, 1, 100, [(filterFCenter_(3)/(44100/2)) (filterFCenter_(4) /(44100/2))]); 
    %[b(3,:), a(3,:)] = ellip(3, 1, 100, [(filterFCenter_(5)/(44100/2)) (filterFCenter_(6) /(44100/2))]); 
    %[b(4,:), a(4,:)] = ellip(3, 1, 100, [(filterFCenter_(7)/(44100/2)) (filterFCenter_(8) /(44100/2))]); 
    
    N     = 8;    % Order
    Fs_d    = Fs;
    Fpass = Fs_d / 4;  % Passband Frequency
    Astop = 80;    % Stopband Attenuation (dB)
    Apass = 1;     % Passband Ripple (dB)
    h = fdesign.lowpass('n,fp,ap,ast', N, Fpass, Apass, Astop, Fs_d);

    filterLP4 = design(h, 'ellip', 'SystemObject', true);
    
    %filterLP4 = dsp.IIRHalfbandDecimator('TransitionWidth',100,'SampleRate',Fs_d);
    
    Fs_d    = Fs/2;
    Fpass = Fs_d / 4  ;  % Passband Frequency
    h = fdesign.lowpass('n,fp,ap,ast', N, Fpass, Apass, Astop, Fs_d);
    filterLP3 = design(h, 'ellip','SystemObject', true);
    %filterLP3 = dsp.IIRHalfbandDecimator('TransitionWidth',50,'SampleRate',Fs_d);
    
    Fs_d    = Fs/4;
    Fpass = Fs_d / 4;  % Passband Frequency
    h = fdesign.lowpass('n,fp,ap,ast', N, Fpass, Apass, Astop, Fs_d);
    filterLP2 = design(h, 'ellip','SystemObject', true);
    %filterLP2 = dsp.IIRHalfbandDecimator();
    %filterLP2 = dsp.IIRHalfbandDecimator('TransitionWidth',25,'SampleRate',Fs_d);
    
    Fs_d    = Fs/8;
    Fpass = Fs_d / 4;  % Passband Frequency
    h = fdesign.lowpass('n,fp,ap,ast', N, Fpass, Apass, Astop, Fs_d);
    filterLP1 = design(h, 'ellip', 'SystemObject', true);
    
    
    SRC1 = dsp.SampleRateConverter('Bandwidth',310,...
    'InputSampleRate',320,'OutputSampleRate',PLLFs);
    SRC2 = dsp.SampleRateConverter('Bandwidth',620,...
    'InputSampleRate',640,'OutputSampleRate',PLLFs);
    SRC3 = dsp.SampleRateConverter('Bandwidth',1240,...
    'InputSampleRate',1280,'OutputSampleRate',PLLFs);
    SRC4 = dsp.SampleRateConverter('Bandwidth',2480,...
    'InputSampleRate',2560,'OutputSampleRate',PLLFs);
    
    
    N     = 6;    % Order
    Fs_d    = Fs;
    Fpass = Fs_d / 4;  % Passband Frequency
    Astop = 80;    % Stopband Attenuation (dB)
    Apass = .1;     % Passband Ripple (dB)

    h = fdesign.highpass('n,fp,ast,ap', N, Fpass, Astop, Apass, Fs_d);
    filterHP4 = design(h, 'ellip', ...
        'SystemObject', true);
  
    Fs_d    = Fs/2;
    Fpass = Fs_d / 4;  % Passband Frequency
    h = fdesign.highpass('n,fp,ast,ap', N, Fpass, Astop, Apass, Fs_d);
    filterHP3 = design(h, 'ellip', ...
        'SystemObject', true);
    Fs_d    = Fs/4;
    Fpass = Fs_d / 4;  % Passband Frequency
    h = fdesign.highpass('n,fp,ast,ap', N, Fpass, Astop, Apass, Fs_d);
    filterHP2 = design(h, 'ellip', ...
        'SystemObject', true);
    Fs_d    = Fs/8;
    Fpass = Fs_d / 4;  % Passband Frequency
    h = fdesign.highpass('n,fp,ast,ap', N, Fpass, Astop, Apass, Fs_d);
    filterHP1 = design(h, 'ellip', ...
        'SystemObject', true);
    

   
    
   
    fLP1 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP2 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP3 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP4 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP5 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP6 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP7 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    fLP8 = dsp.IIRFilter('Structure', 'Direct form II', 'Numerator',bLp , 'Denominator', aLp);
    
   
    envDet1 = EnvDetector;
    envDet5 = EnvDetector;
    envDet6 = EnvDetector;
    pllTracker1 = PLLClass(fCenter(1),Kd(1),PLLFs);
    setSampleRate(pllTracker1,PLLFs);
    pllTracker2 = PLLClass(fCenter(2),Kd(2),PLLFs);
    setSampleRate(pllTracker2,PLLFs);
    envDet2 = EnvDetector;
    pllTracker3 = PLLClass(fCenter(3),Kd(3),PLLFs);
    setSampleRate(pllTracker3,PLLFs);
    pllTracker4 = PLLClass(fCenter(4),Kd(4),PLLFs);
    setSampleRate(pllTracker4,PLLFs);
    envDet3 = EnvDetector;
    pllTracker5 = PLLClass(fCenter(5),Kd(5),PLLFs);
    setSampleRate(pllTracker5,PLLFs);
    pllTracker6 = PLLClass(fCenter(6),Kd(6),PLLFs);
    setSampleRate(pllTracker6,PLLFs);
    envDet4 = EnvDetector;
    pllTracker7 = PLLClass(fCenter(7),Kd(7),PLLFs);
    setSampleRate(pllTracker7,PLLFs);
    pllTracker8 = PLLClass(fCenter(8),Kd(8),PLLFs);
    setSampleRate(pllTracker8,PLLFs);
    
     
    setSampleRate(envDet1,Fs);
    setSampleRate(envDet2,Fs);
    setSampleRate(envDet3,Fs);
    setSampleRate(envDet4,Fs);
    setSampleRate(envDet5,Fs);
    setSampleRate(envDet6,Fs);
    
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
    
    if stopFlag
        release(pllTracker1);
        release(pllTracker2);
        release(pllTracker3);
        release(pllTracker4);
        release(pllTracker5);
        release(pllTracker6);
        release(pllTracker7);
        release(pllTracker8);
        release(envDet1);
        release(envDet2);
        release(envDet3);
        release(envDet4);
        release(filterLP1);
        release(filterLP2);
        release(filterLP3);
        release(filterLP4);
        release(filterHP1);
        release(filterHP2);
        release(filterHP3);
        release(filterHP4);
        release(fLP1);
        release(fLP2);
        release(fLP3);
        release(fLP4);
        release(fLP5);
        release(fLP6);
        release(fLP7);
        release(fLP8);
        
    end
    
    
    x4 = step(filterHP4, x);
    xlp4 = step(filterLP4,x);
 
    x3in = downsample(xlp4,2);
    %x3in = xlp4;
    x3 = step(filterHP3, x3in);
    xlp3 = step(filterLP3,x3in);
    
    
    x2in = downsample(xlp3,2);
    %x2in = xlp3;
    x2 = step(filterHP2, x2in);
    xlp2 = step(filterLP2,x2in);
    
    x1in = downsample(xlp2,2);
    %x1in = xlp2;
    x1 = step(filterHP1, x1in);
    %x2lp = step(filterLP1,x1in);
    
   
    
    x1 = step(SRC1,x1);
   
    x2 = step(SRC2,x2);
    
    x3 = step(SRC3,x3);
   
    x4 = step(SRC4,x4);
    
    
    
    [x1, env1] = step(envDet1,x1);
    [x2, env2] = step(envDet2,x2);
    [x3, env3] = step(envDet3,x3);
    [x4, env4] = step(envDet4,x4);
    

    
    %x1 = step(envDet5,x1);
    %x2 = step(envDet6,x2);
  
    
    KdFactor = 1;
    
    pllTracker1.fCenter = fCenter(1);
    pllTracker1.Kd    = Kd(1) * KdFactor;
    temp1 = step(pllTracker1,x1);
    pitch(:,1) = temp1;
    %pitch(:,1) = step(fLP1,pitch(:,1));
    pllTracker2.fCenter = fCenter(2);
    pllTracker2.Kd    = Kd(2) * KdFactor;
    temp2 = step(pllTracker2,x1);
    pitch(:,2) = temp2;
    %pitch(:,2) = step(fLP2,pitch(:,2));
    
    
    pllTracker3.fCenter = fCenter(3);
    pllTracker3.Kd    = Kd(3) * KdFactor;
    temp3 = step(pllTracker3,x2);
    pitch(:,3) = temp3;
    %pitch(:,3) = downsample(temp3,2);
    %pitch(:,3) = step(fLP3,pitch(:,3));
    
    pllTracker4.fCenter = fCenter(4);
    pllTracker4.Kd    = Kd(4) * KdFactor;
    temp4 = step(pllTracker4,x2);
    pitch(:,4) = temp4;
    %pitch(:,4) = downsample(temp4,2);
    %pitch(:,4) = step(fLP4,pitch(:,4));
    
   
    
    pllTracker5.fCenter = fCenter(5);
    pllTracker5.Kd    = Kd(5);
    temp5 = step(pllTracker5,x3);
    pitch(:,5) = temp5;
    %pitch(:,5) = downsample(temp5,4);
    %pitch(:,5) = step(fLP5,pitch(:,5));
    
    pllTracker6.fCenter = fCenter(6);
    pllTracker6.Kd    = Kd(6);
    temp6 = step(pllTracker6,x3);
    pitch(:,6) = temp6;
    %pitch(:,6) = downsample(temp6,4);
    %pitch(:,6) = step(fLP6,pitch(:,6));
    
    pllTracker7.fCenter = fCenter(7);
    pllTracker7.Kd    = Kd(7);
    temp7 = step(pllTracker7,x4);
    pitch(:,7) = temp7;
    %pitch(:,7) = downsample(temp7,8);
    %pitch(:,7) = step(fLP7,pitch(:,7));
     
    pllTracker8.fCenter = fCenter(8);
    pllTracker8.Kd    = Kd(8);
    temp8 = step(pllTracker8,x4);
    pitch(:,8) = temp8;
    %pitch(:,8) = downsample(temp8,8);
    %pitch(:,8) = step(fLP8,pitch(:,8));
    
%     subplot(4,1,1);
%     hold on;
%     plot(x1)
%     subplot(4,1,2);
%     hold on;
%     plot(x2);
%     subplot(4,1,3);
%     hold on;
%     plot(x3);
%     subplot(4,1,4);
%     hold on;
%     plot(x4);
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
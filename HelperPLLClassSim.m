function [input,pitch,pauseSim,stopSim, resetSim, output] = HelperPLLClassSim(in, Fs, BS)
% HELPERPITCHSHIFTERSIM Implements algorithm used in delay-based pitch
% shifter example. This function instantiates, initializes and steps
% through the System objects used in the algorithm.
%
% You can tune the simulation properties through the UI that
% appears when audioPitchShifterExampleApp is executed.

%   Copyright 2015 The MathWorks, Inc.

%#codegen

persistent  player fCenter filterFCenter Kd SRC
%frameSize = 4096;
if isempty(player)
    %reader = dsp.AudioFileReader('AR_Lick11_picked_N.wav',...
    %5                             'SamplesPerFrame',256,'PlayCount',Inf,'OutputDataType', 'double');
    %player = audioDeviceWriter('SampleRate',reader.SampleRate,'BufferSize',256);
    player = audioDeviceWriter('SampleRate',44100,'BufferSize',4410);
    
    SRC = dsp.SampleRateConverter('Bandwidth',2560/2,...
            'InputSampleRate',44.1e3,'OutputSampleRate',2560);
    [L,M] = getRateChangeFactors(SRC);

    
    startFreq = 80.06;
    fCenter = zeros(1,8);
    filterFCenter = zeros(1,8);
    Kd = zeros(1,8);
    
    for i = 1 : 4
        filterFCenter((i - 1) * 2 + 1) = startFreq * 2^(((1200 * (i-1)))/1200);
        filterFCenter(i * 2) = startFreq * 2^(((1200 * i))/1200);
        fCenter((i - 1) * 2 + 1) =  startFreq * 2^(((1200 * (i-1))- 100)/1200);
        fCenter(i * 2) = startFreq * 2^(((1200 * i) + 100)/1200);
        Kd((i - 1) * 2 + 1) = 290 * i;
        Kd(i * 2) = 290 * i;
    end
end

[paramNew, simControlFlags] = HelperUnpackUDP();

input = zeros(256,1);
output = zeros(256,1);
pitch = zeros(256 * 2,1);
pauseSim = simControlFlags.pauseSim;
stopSim = simControlFlags.stopSim;
resetSim = simControlFlags.resetObj;

if  stopSim
    trackPitch(input,256,fCenter,filterFCenter,Kd,Fs,false,true);
    %trackPitch_least_pth(input,256,fCenter,filterFCenter,Kd,Fs,false,true);
    return;  % Stop the simulation
end
if simControlFlags.pauseSim
    return; % Pause the simulation (but keep checking for commands from GUI)
end

% Tune parameters if needed
if ~isempty(paramNew)
    for i =1:8
        fCenter(i)   = paramNew((i - 1) * 2 + 1);
        Kd(i) = paramNew(i * 2);
    end
       
    if resetSim % reset System objects
        %reset(reader);
        % Reset pitch shifter
        trackPitch(input,256,fCenter,filterFCenter,Kd,Fs,true,false);
        %trackPitch_least_pth(input,256,fCenter,filterFCenter,Kd,Fs,true,false);
    end
end
ind = step(SRC,in);
%x = step(reader);
pitch =  trackPitch(ind,256,fCenter, filterFCenter, Kd,Fs,false,false);
%pitch = trackPitch_least_pth(ind,256,fCenter,filterFCenter,Kd,Fs,false,false);
step(player,in); 

input  = ind(:,1);
output = ind(:,1);

end
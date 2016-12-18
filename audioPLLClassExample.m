
function scopeHandles = audioPLLClassExample(filename,usemex,showVisual,numTSteps)
%audioPitchShifterExampleApp Graphical interface for audio pitch shifter. 
%
% Inputs:
%   usemex     - If true, MEX-file is used for simulation for the
%                algorithm. Default value is false. Note: in order to use
%                the MEX file, first execute:
%                codegen HelperPitchShifterSim -o HelperPitchShifterSimMEX
%   showVisual - Display scopes
%   numTSteps  - Number of time steps. Default value is infinite
%
% Output:
%   scopeHandles - Handle to scopes
%
% This function audioPitchShifterExampleApp is only in support of
% audioPitchShifterExample. It may change in a future release.

% Copyright 2015 The MathWorks, Inc.

%#codegen
%% Default values for inputs
if nargin < 3
    numTSteps = Inf; % Run until user stops simulation. 
end
if nargin < 3
    showVisual = true; % Plot results  
end
if nargin == 1
    usemex = false; % Do not generate code.
end

FS = 2560;
pitchDownSampleFactor = 44100 / (FS);
displayDownSampleFactor = 1 ;
screen = get(0,'ScreenSize');
outerSize = min((screen(4)-40)/2, 512);
    
% Create scopes only if plotResults is true
if showVisual     
    scope = dsp.TimeScope('TimeSpan',4,'YLimits',[0,1400],...
        'SampleRate',FS/displayDownSampleFactor/8,'LayoutDimensions',[1 1],...
        'NumInputPorts',1,'TimeSpanOverrunAction','Scroll');
    scope.ActiveDisplay = 1;
    scope.Title = 'Pitch';
    scope.YLabel = 'Hz';
    scope.ShowGrid = true;
    %scope.YLimits = [0,30];
%     scope.ActiveDisplay = 2;
%     scope.Title = 'Gains';
%     scope.YLabel = 'Amplitude';
%     scope.ShowGrid = true;
%     scope.YLimits = [0,1];
%     scope.ActiveDisplay = 3;
%     scope.Title = 'Input vs. Output Signals';
%     scope.YLabel = 'Amplitude';
%     scope.ShowGrid = true;
%     scope.YLimits = [-1,1];
else
    scope = [];
end
resetPlayer = 0;
stopPlayer = 0;
startFreq = 80.06;
freqsPll = zeros(1,8);
Kd = zeros(1,8);

for i= 1:4
         freqsPll((i - 1) * 2 + 1) = startFreq * 2^(((1200 * (i-1)))/1200);
         freqsPll((i - 1) * 2 + 2) = startFreq * 2^(((1200 * i))/1200);
         Kd((i - 1) * 2 + 1) = 290 * i; 
         Kd(i * 2) = 290 * i;
end
% Define parameters to be tuned
param = struct([]);
for i = 1: 8
    param((i - 1) * 2 + 1).Name = strcat('fCenter', num2str(i));
    param((i - 1) * 2 + 1).InitialValue = freqsPll(i);
    %param((i - 1) * 2 + 1).InitialValue = 200;
    param((i - 1) * 2 + 1).Limits = [74,1500];
    param((i - 1) * 2 + 2).Name = strcat('Kd', num2str(i));
    param((i - 1) * 2 + 2).InitialValue = Kd(i);
    %param((i - 1) * 2 + 2).InitialValue = 800;
    param((i - 1) * 2 + 2).Limits = [0, 2000];   
end

reader = dsp.AudioFileReader(filename,...
                                'SamplesPerFrame',2205*2,'PlayCount',Inf,'OutputDataType', 'double'); 

% Create the UI and pass it the parameters
hUI = HelperCreateParamTuningUI(param, 'Pitch Tracker');
set(hUI,'Position',[outerSize+32, screen(4)-2*outerSize+8, ...
    outerSize+8, outerSize-92]);

clear HelperPllClassSim
clear HelperPllClassSimMex
clear HelperUnpackUDP
clear trackPitch

% Execute algorithm
while(numTSteps>=0)
     in = step(reader);
     %in = resample(in,100, 172);
     %in = downsample(in,downSampleFactor);
    if ~usemex
       [x,pitch,pauseSim, stopSim, resetSim] = HelperPLLClassSim(in, FS, 256);
    else
        [x,pitch,pauseSim, stopSim,resetSim] = HelperPLLClassSim_mex(in, FS, 256);
    end
    pitch = downsample(pitch,displayDownSampleFactor);
    if resetSim
       reset(reader);
    end
    if stopSim     % If "Stop Simulation" button is pressed
        break;
    end
    drawnow limitrate;   % needed to flush out UI event queue
    if pauseSim
        continue;
    end
    if showVisual
        step(scope,pitch);
    end
    numTSteps = numTSteps - 1;
end

if ishghandle(hUI)  % If parameter tuning UI is open, then close it.
    delete(hUI);
    drawnow;
    clear hUI
end
  
if showVisual
    scopeHandles.scope = scope;
end
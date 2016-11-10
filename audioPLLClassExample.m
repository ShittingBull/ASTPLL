function scopeHandles = audioPLLClassExample(filename,usemex,showVisual,numTSteps)

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

downSampleFactor = 5;
displayDownSampleFactor = 300;
screen = get(0,'ScreenSize');
outerSize = min((screen(4)-40)/2, 512);

% Create scopes only if plotResults is true
if showVisual
    scope = dsp.TimeScope('TimeSpan',5,'YLimits',[0,1400],...
        'SampleRate',44100/downSampleFactor/displayDownSampleFactor,'LayoutDimensions',[1 1],...
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
    freqsPll((i - 1) * 2 + 1) = startFreq * 2^(((1200 * (i-1))- 100)/1200);
    freqsPll((i - 1) * 2 + 2) = startFreq * 2^(((1200 * i) + 100)/1200);
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
    'SamplesPerFrame',256*downSampleFactor,'PlayCount',Inf,'OutputDataType', 'double');

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
    in = downsample(in,downSampleFactor);
    if ~usemex
        [x,pitch,pauseSim, stopSim, resetSim] = HelperPLLClassSim(in, reader.SampleRate/downSampleFactor, reader.SamplesPerFrame/downSampleFactor);
    else
        [x,pitch,pauseSim, stopSim,resetSim] = HelperPLLClassSim_mex(in, reader.SampleRate/downSampleFactor, reader.SamplesPerFrame/downSampleFactor);
    end
    pitch = downsample(pitch,displayDownSampleFactor);
    if resetSim
        reset(reader);
    end
    if stopSim     % If "Stop Simulation" button is pressed
        release (scope);
        clear all;
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
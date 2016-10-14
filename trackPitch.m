function [pitch] = trackPitch(x, bufferSize, fCenter, Kd, Fs, resetFlag)
% shiftPitch This function is used in audioPitchShifterExample

%  Copyright 2015 The MathWorks, Inc.

%#codegen
pitch = zeros(bufferSize,8);
persistent pllTracker1 pllTracker2 pllTracker3 pllTracker4 pllTracker5 pllTracker6 pllTracker7 pllTracker8;
persistent envDet1 envDet2 envDet3 envDet4 envDet5 envDet6 envDet7 envDet8 ;
if isempty(pllTracker1)

           pllTracker1 = PLLClass(fCenter(1),Kd(1),Fs);
           setSampleRate(pllTracker1,Fs);
           envDet1 = EnvDetector;
           pllTracker2 = PLLClass(fCenter(2),Kd(2),Fs);
           setSampleRate(pllTracker2,Fs);
           envDet2 = EnvDetector;
           pllTracker3 = PLLClass(fCenter(3),Kd(3),Fs);
           setSampleRate(pllTracker3,Fs);
           envDet3 = EnvDetector;
           pllTracker4 = PLLClass(fCenter(4),Kd(4),Fs);
           setSampleRate(pllTracker4,Fs);
           envDet4 = EnvDetector;
           pllTracker5 = PLLClass(fCenter(5),Kd(5),Fs);
           setSampleRate(pllTracker5,Fs);
           envDet5 = EnvDetector;
           pllTracker6 = PLLClass(fCenter(6),Kd(6),Fs);
           setSampleRate(pllTracker6,Fs);
           envDet6 = EnvDetector;
           pllTracker7 = PLLClass(fCenter(7),Kd(7),Fs);
           setSampleRate(pllTracker7,Fs);
           envDet7 = EnvDetector;
           pllTracker8 = PLLClass(fCenter(8),Kd(8),Fs);
           setSampleRate(pllTracker8,Fs);
           envDet8 = EnvDetector;
           flatEnvThresh = 10^(-50/20);
 
    end


if nargin < 6
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
    
    
            pllTracker1.fCenter = fCenter(1);
            pllTracker1.Kd    = Kd(1);
            x = step(envDet1,x);     
            pitch(:,1) = step(pllTracker1,x); 
             
            pllTracker2.fCenter = fCenter(2);
            pllTracker2.Kd    = Kd(2); 
            %x = envDet2(x);
            pitch(:,2) = step(pllTracker2,x);
            
            pllTracker3.fCenter = fCenter(3);
            pllTracker3.Kd    = Kd(3);  
            %x = envDet3(x);
            pitch(:,3) = step(pllTracker3,x);
            
            pllTracker4.fCenter = fCenter(4);
            pllTracker4.Kd    = Kd(4);
            %x = envDet4(x);
            pitch(:,4) = step(pllTracker4,x);
            
            pllTracker5.fCenter = fCenter(5);
            pllTracker5.Kd    = Kd(5); 
            %x = envDet5(x);
            pitch(:,5) = step(pllTracker5,x); 
            
            pllTracker6.fCenter = fCenter(6);
            pllTracker6.Kd    = Kd(6);
            %x = envDet6(x);
            pitch(:,6) = step(pllTracker6,x);
            
            pllTracker7.fCenter = fCenter(7);
            pllTracker7.Kd    = Kd(7);
            %x = envDet7(x);
            pitch(:,7) = step(pllTracker7,x);
            
            pllTracker8.fCenter = fCenter(8);
            pllTracker8.Kd    = Kd(8);
            %x = envDet8(x);
            pitch(:,8) = step(pllTracker8,x);
             
            


     
    
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
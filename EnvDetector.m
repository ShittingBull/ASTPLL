classdef EnvDetector < audioPlugin & matlab.System
    %ENVDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    y = 0;    
    state = 0;  
    state2 = 0;
    
    end
    properties (Constant)
        flatEnvThresh = 10 ^(-50/20);
    end
    
    methods  (Access = protected)
        function [out, env] = stepImpl(plugin, in)
           
            [samples, channels] = size(in);
            out = zeros(samples,1);
            env = zeros(samples,1);
            tmp = zeros(samples,1);
            persistent fs tauAttack tauRelease
            fs = plugin.getSampleRate;
            tauAttack = 0.05;
            tauRelease = 0.1;
            
            taufs = tauRelease * fs;
            if tauRelease > 0
                alphaRel = exp(-1 / taufs);
            else
                alphaRel = 0;
            end
            
            for i=1:samples
                if in(i) > plugin.state
                    plugin.state = in(i);
                else
                    plugin.state =alphaRel * plugin.state + (1-alphaRel) *in(i);
                end
                tmp(i) = plugin.state;
            end
            

            taufs = tauAttack * fs;
            if tauAttack > 0
                alphaAtt = exp(-1 / taufs);
            else
                alphaAtt = 0;
            end
           
            
            for i=1:samples
                plugin.state2 = alphaAtt * plugin.state2 + (1-alphaAtt) * tmp(i);
                env(i) = plugin.state2;
                if env(i) > plugin.flatEnvThresh
                    out(i) = (1 / env(i)) * in(i);  
                else 
                    out(i) = in(i);
                end
                
                
            end
            
        end
    end
    
end


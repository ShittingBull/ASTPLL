classdef PLLClass < audioPlugin & matlab.System
    properties (Constant)
        %BPll = [2.6715e-06 5.3429e-06 2.6715e-06];
        %APll = [1 -1.9902 0.9902];
        BPll = 0;%[7.942424934056017e-05 1.588484986811203e-04 7.942424934056017e-05];
        APll = 0;%[1 -1.9469 0.9472];
    end
    properties
        F0 = 0
        filtPll = zeros(1,5); %filterStates
        fCenter = 200;
        K0 = 2;
        Kd = 800;
        fs = 0;  
        BiQu;
        xd = 0;
        yc = 0;
        xdLp = 0;
        fOsc = 0;
        phasecounter = 0;
    end
    
    properties (Constant)
        alpha = 0.35;
        fcPll = 23;
        
        % Define plug-in interface
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('fCenter',...
            'DisplayName','PLL Center Frequency',...
            'Label','Hz',...
            'Mapping',{'int',80,800}),...
            'InputChannels',1,...
            'OutputChannels',1);%,...
%            audioPluginParameter('F0',...
%             'DisplayName','F0',...
%             'Label','Hz',...
%             'Mapping',{'int',0,800}));
    end

    
    
    
     methods (Access = public)
         
         function setProps(plugin, nargin, varargin)
            if nargin>0
                plugin.fCenter = varargin{1};
            end
            if nargin>1
                plugin.Kd = varargin{2};
            end
            if nargin>2
                plugin.fs = varargin{3};
            end
          end
          function plugin = PLLClass(varargin)
            setProps(plugin, nargin, varargin{:});
            K = tan(pi * 10 / (plugin.fs));
            %K = tan(0.0016);
            param = 1/3;
            N =  K*K*param + K + param;
            a1 = (2*param*(K*K-1)) / N;
            a2 = (K*K*param-K+param)/N;
            b0 = K*K*param / N;
            b1 = 2*K*K*param/N;
            b2 = b0;  
            %[BPll, APll] = getFilterCoeff(23,plugin.getSampleRate,1/3,'lowpass')
            %plugin.BiQu =  dsp.BiquadFilter('Structure', 'Direct form I', 'SOSMatrix',[BPll APll]);
            plugin.BiQu =  dsp.BiquadFilter('Structure', 'Direct form II', 'SOSMatrix',[b0 b1 b2 1 a1 a2]);
           
             
          end
          
     end
     methods (Access = protected)
         
         function  applyFiltering(plugin)
            
            sampleOut = plugin.BPll(1) * plugin.xd + plugin.BPll(2) * plugin.filtPll(1) + plugin.BPll(3) * plugin.filtPll(2)  - plugin.APll(2) * plugin.filtPll(3) - plugin.APll(3) * plugin.filtPll(4);
            plugin.filtPll(2:4) = plugin.filtPll(1:3);
            plugin.filtPll(3) = sampleOut;
            plugin.filtPll(1) = plugin.xd;
            plugin.xdLp = sampleOut;
        
         end  
        
        function out = stepImpl(plugin, in)
           
            [samples, channels] = size(in);
            out = zeros(samples,1);
  
            %temp = zeros(samples,1);
            %plugin.xdLp = step(plugin.BiQu,in');
            %fvtool(plugin.BiQu);
                for i = 1: samples                
                    plugin.xd = in(i,1) * plugin.yc * plugin.Kd;
                    %xd_(i) = plugin.xd;
                    %applyFiltering(plugin);
                    plugin.xdLp = step(plugin.BiQu,plugin.xd);
                    %xdLp_(i) = plugin.xdLp;
                    plugin.F0 = plugin.fCenter + plugin.K0 * plugin.xdLp;
                    %plugin.F0 = plugin.fCenter + plugin.xdLp;
                    plugin.fOsc = plugin.K0 *(plugin.xdLp*(1- plugin.alpha) + plugin.xd * plugin.alpha) + plugin.fCenter;
                    %fosc_(i) = plugin.fOsc;
                    %plugin.fOsc = plugin.xdLp*(1- plugin.alpha) + plugin.xd * plugin.alpha + plugin.fCenter;
                    plugin.phasecounter = mod(plugin.phasecounter + plugin.fOsc/plugin.getSampleRate * 2 * pi, 2 * pi);
                    %phasecounter_(i) = plugin.phasecounter;
                    plugin.yc = cos(plugin.phasecounter + pi/ 2 );
                    %yc_(i) = plugin.yc;
                    out(i,1) = plugin.F0;

                    %plugin.F0;
                    %in
                end
            %out = temp;
            %dsp.ArrayPlot(temp);
            %out = in;
        end
        
       
        
        function resetImpl(plugin)
            plugin.xd = 0;
        end
     end
        
 end    

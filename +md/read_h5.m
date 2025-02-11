function[tlh5]= read_h5(folder)

%%
estim = h5read(folder,'//AI/E_Stim'); 
mforce = h5read(folder,'//AI/M_Force'); 
mlength = h5read(folder,'//AI/M_Length'); 
pedal = h5read(folder,'//AI/Pedal');
peltier = h5read(folder,'//AI/Pelt_Temp');
piezo = h5read(folder,'//AI/PiezoMonitor');
pockels= h5read(folder,'//AI/PockelsMonitor');

framecount = h5read(folder,'//CI/FrameCounter');

frames =h5read(folder,'//DI/2pFrames');
captureactive = h5read(folder,'//DI/CaptureActive');
pandaframes = h5read(folder,'//DI/PandaFrames');

fithz = h5read(folder,'//Freq/FitHz');%also all zeros 
%hz = h5read(folder,'//Freq/Hz'); %all zeros for some reason 

gctr = h5read(folder,'//Global/GCtr');

%%

tlh5= table(estim',mforce',mlength',pedal',peltier',piezo',pockels',framecount',frames',captureactive',pandaframes',gctr'); 

tlh5.Properties.VariableNames={'estim','mforce','mlength','pedal','peltier','piezo','pockels','framecount','frames','captureactive','pandaframes','gctr'}; 


%% TO ADD TO THIS FUNCTION 
% CHECK VARIABLES/ INFO IN THE XML 
% 
% thorsync_xml = importxml('/Volumes/Potter/#518/Final FOV/ThorSync/TS_SDH#518/ThorRealTimeDataSettings.xml'); 

% only thing I can think to add is if enable =1 for khz = 30k 
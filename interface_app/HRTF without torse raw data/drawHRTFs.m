%% This program is to read HRTFs in the workspace and draw graphs
clear; close all; clc;
fileID = fopen('HRTFs_AzEl_AES_Torso','r');
if(fileID == -1)
    printf('Failed to open file HRTFs');
    return;
end
fmin = 0;
fmax = 12000;
c = 343;
freqStep = 25;
azStart = 0;
azEnd = 330;
numFreqs = (fmax-fmin)/freqStep+1;
azStep = 30;
numAzs = (azEnd-azStart)/azStep+1;
elStart = -36;
elEnd = 54;
elStep = 18;
numEls = (elEnd-elStart)/elStep+1;
numSrcs = numAzs*numEls;
radius = 1;
HRTFs = zeros(2*numSrcs,numFreqs);
colors = ['m','b','r','g','y','c'];
format = '';
s = '(%f,%f) ';
for i=1:numFreqs
    format = [format,s];
end
%%
for i=1:2*numSrcs
    tline = fgetl(fileID);
    a = sscanf(tline,format);
    for j=1:numFreqs
        x = a(2*j-1);
        y = a(2*j);
        HRTFs(i,j) = x+complex(0,1)*y;
    end
end
fclose(fileID);

ctr = [0,0,0];
srcs = zeros(numSrcs,3);
for i=1:numEls
    for j=1:numAzs
        srcs((i-1)*numAzs+j,:) = [radius*cos(azStart+(j-1)*azStep),radius*sin(azStart+(j-1)*azStep),...
            radius*tan(elStart+(i-1)*elStep)];
    end
end

%%
fs = 2*fmax; % The standard sampling frequency
numFreqs_fs = (fs-freqStep)/freqStep+1;
HRTFs_fs = zeros(2*numSrcs,numFreqs_fs);
HRTFs_fs(:,1:numFreqs-1) = HRTFs(:,1:numFreqs-1); % 0 to 19975
temp = HRTFs(:,2:numFreqs);
temp = conj(temp);
temp = temp(:,end:-1:1);
HRTFs_fs(:,numFreqs:end) = temp;
HRIRs = real(ifft(HRTFs_fs,[],2));

save('HRIR_wTorso.mat','HRIRs');

% %%
% ref = zeros(numSrcs,numFreqs);
% for i=1:numSrcs
%     for j=1:numFreqs
%         ref(i,j) = green(2*pi*(j-1)*freqStep/c,ctr,srcs(i,:));
%     end
% end
% figure;
% idx = 0;
% for i=1:numEls
%     idx = 6+(i-1)*numAzs;
%     plot(0+freqStep*(0:numFreqs-1),10*log10(abs(HRTFs(idx,:)).^2./(abs(ref(idx,:)).^2)),'color',colors(i));
%     hold on;
%     C{i} = strcat('Elevation: ',num2str(elStart+(i-1)*elStep));
% end
% title('computed');
% xlabel('Freqency(Hz)');
% ylabel('Pressure(dB)');
% legend(C);
% 
% load('KEMAR_MED2_2017_DEC-22.mat');
% HRIRs_m = zeros(size(rawData,3)*2,size(rawData,2));
% 
% 
% 

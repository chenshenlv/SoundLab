load('HRIRs.mat');
HRIRs_w_torso=HRIRs;
HRIRs_w_torso_l=HRIRs_w_torso(49:49+23,:);
HRIRs_w_torso_r=HRIRs_w_torso(49+144:49+23+144,:);
for i=1:size(HRIRs_w_torso_l,1)
    HRTF(i).az=(i-1)*15;
    HRTF(i).hrir_l=HRIRs_w_torso_l(i,:);
    HRTF(i).hrir_r=HRIRs_w_torso_r(i,:);
    HRTF(i).srate=24000;
end
save('HRTF_w_torso.mat','HRTF')

HRTF=[];
load('KEMAR_MED2_2017_DEC-22.mat')
right=rawData(1,:,:);
left=rawData(2,:,:);
right=squeeze(right);
left=squeeze(left);
k=1;
for i=1:length(elevation_array)
    for j=1:length(azimuth_array)
        HRTF1(k).el=elevation_array(i);
        HRTF1(k).az=azimuth_array(j);
        HRTF1(k).hrir_r=right(:,k)';
        HRTF1(k).hrir_l=left(:,k)';
        HRTF1(k).srate=srate;
        k=k+1;
    end
end
for i=1:12
    HRTF(i).az=(i-1)*30;
end
for i=1:6 
    HRTF(i).hrir_r=HRTF1(i+30).hrir_r;
    HRTF(i).hrir_l=HRTF1(i+30).hrir_l;
end
for i=7:12
    HRTF(i).hrir_r=HRTF1(i+18).hrir_r;
    HRTF(i).hrir_l=HRTF1(i+18).hrir_l;
end
for i=1:12
    HRTF(i).srate=srate;
end

save('HRTF_med.mat','HRTF')
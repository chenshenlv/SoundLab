function table_t = createData()
%CREATEDATA Creates fake data for analysis
%   Detailed explanation goes here

data = struct();

subjects = 1:1:7;
az = 0;

i = 1;
for subj = subjects
            % only use 0 az as example
            data.truth(1,i) = az;
            data.subject(1,i) = subj;
            % hrtf 1's avg error
            data.selected1(1,i) = randi([az-5, az+5]);
            data.error1(1,i) = abs(data.truth(1,i) - data.selected1(1,i));
            % hrtf 2's avg error
            data.selected2(1,i) = randi([az-10, az+10]);
            data.error2(1,i) = abs(data.truth(1,i) - data.selected2(1,i));
            %hrtf 3's avg error
            data.selected3(1,i) = randi([az-3, az+3]);
            data.error3(1,i) = abs(data.truth(1,i) - data.selected3(1,i));
            i = i + 1;
end

table_t = table( ...
    data.subject', ...
    data.truth', ...
    data.error1', ...
    data.error2', ...
    data.error3', ...
    'VariableNames', ...
    {'Subject','Truth','HRTFerr1','HRTFerr2','HRTFerr3'})
    
end


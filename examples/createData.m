function table_t = createData()
%CREATEDATA Creates fake data for analysis
%   Detailed explanation goes here

data.subject = zeros(1,10*3*4); % will use 10 subjects
data.hrtf = zeros(1,10*3*4,1); % 3 hrtfs
data.truth = zeros(1,10*3*4,1); % will use 90 degree increments as test
data.selected = zeros(1,10*3*4,1);
data.error = zeros(1,10*3*4,1);

subjects = 1:1:20;
hrtfs = 1:1:3;
azimuths = 0:45:270;

i = 1;
for subj = subjects
    for hrtf = hrtfs
        for az = azimuths
            data.truth(1,i) = az;
            data.hrtf(1,i) = hrtf;
            data.subject(1,i) = subj;
            data.selected(1,i) = randi([az-5, az+5]);
            data.error1(1,i) = abs(data.truth(1,i) - data.selected(1,i));
            data.selected(1,i) = randi([az-10, az+10]);
            data.error2(1,i) = abs(data.truth(1,i) - data.selected(1,i));
            data.selected(1,i) = randi([az-3, az+3]);
            data.error3(1,i) = abs(data.truth(1,i) - data.selected(1,i));
            data.selected(1,i) = randi([az-4, az+4]);
            data.error4(1,i) = abs(data.truth(1,i) - data.selected(1,i));
            data.selected(1,i) = randi([az-1, az+1]);
            data.error5(1,i) = abs(data.truth(1,i) - data.selected(1,i));
            i = i + 1;
        end    
    end
end
    
table_t = table(...
data.subject', ...
data.hrtf', ...
data.truth', ...
((data.error1 + ...
data.error2 + ...
data.error3 + ...
data.error4 + ...
data.error5)/5)', ...
'VariableNames', ...
{'Subject';'HRTF';'Truth';'AvgError'});

end


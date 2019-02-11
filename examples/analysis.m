clc;
clear;

% step 1: preprocess data.  This is only an example of data.  
% actual data wil require different preprocessing.  Use this for
% guidance.
data = createData();
rows = data.Truth==0;
vars = {'HRTF','AvgError'};
analysis_table = data(rows,vars);
anova_data = table2array(analysis_table)';

% prepping anova data
y = anova_data(2,:);
group = anova_data(1,:);

% check norm
figure;
normplot(y)

% perform anova
[p,tbl,stats] = anova1(y, group);

% perform multicompare
[c,m,h,nms] = multcompare(stats);

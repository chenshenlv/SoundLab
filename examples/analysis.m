clc;
clear;

% step 1: preprocess data.  This is only an example of data.  
% actual data wil require different preprocessing.  Use this for
% guidance.
data = createData();

err = table([1 2 3]','VariableNames',{'Errors'});
rm = fitrm(data,'HRTFerr1-HRTFerr3~1','WithinDesign',err);

% check sphericity (auto done in ranova)
mauchly(rm)

% repeated measure anova
ranova(rm)

% state result:
% F(2,12) = Fstat, p = pValue

% a=[];
% for i=1:3
%     for j=1:60
%         a=[a,i];
%     end
% end
% b=[];
% for i=1:15
%     for j=1:12
%         b=[b,j];
%     end
% end
% c=[a;b];
% r=randperm(size(c,2));
% c=c(:,r);
load('D:\Course\individual study\SoundLab\interface_app\Reload\R_azs_array.mat');
load('D:\Course\individual study\SoundLab\interface_app\Reload\R_hrtf_array.mat');
a=R_hrtf_array_for_save;
b=R_azs_array_for_save;
d=zeros(3,12);
for i=1:180
    for j=1:12
        if a(1,i)==2 && b(1,i)==j
            d(2,j)=d(2,j)+1;
        end
    end
end
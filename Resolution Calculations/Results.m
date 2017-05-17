clear all
clc
minRange = 500;
maxRange = 3000;
minHeight = 500;
maxHeight = 10000;
idealRange = 1500;
idealHeight = 1500;

theta_min = atand(minHeight/maxRange);
theta_max = atand(maxHeight/minRange);
Broad_ang = atand(idealHeight/idealRange);

vals=csvread('simulationResults_128_30_0.csv',1,0);
A=vals(:,7);
fprintf('min = %8.3f\n',min(A))
fprintf('max = %8.3f\n',max(A))
fprintf('range = %8.3f\n',range(A))
fprintf('total = %d\n',size(A,1))

fprintf('Deltas\n\n')
D=A(2:end)-A(1:end-1);
fprintf('mean = %8.3f\n',mean(D))
fprintf('median = %8.3f\n',median(D))
fprintf('standard deviation = %8.3f\n',std(D))
[v,lm]=min(D);
fprintf('min = %8.3f\n',v)
fprintf('min angles = %8.3f, %8.3f\n',A(lm+1),A(lm))
[v,l]=max(D);
fprintf('max = %8.3f\n',v)
fprintf('max angles = %8.3f, %8.3f\n\n',A(l+1),A(l))

fprintf('Horizontal error @%dm high = %8.3fm\n',minHeight,abs(minHeight/tand(A(l+1)+Broad_ang)-minHeight/tand(A(l)+Broad_ang)))
fprintf('Horizontal error @%dm high = %8.3fm\n',maxHeight,abs(maxHeight/tand(A(l+1)+Broad_ang)-maxHeight/tand(A(l)+Broad_ang)))
fprintf('Vertical error @%dm away = %8.3fm\n',minRange,abs(minRange*tand(A(l+1)+Broad_ang)-minRange*tand(A(l)+Broad_ang)))
fprintf('Vertical error @%dm away = %8.3fm\n',maxRange,abs(maxRange*tand(A(l+1)+Broad_ang)-maxRange*tand(A(l)+Broad_ang)))
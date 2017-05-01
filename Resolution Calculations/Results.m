clear all
clc
Broad_ang=59.0362;

vals=csvread('simulationResults_100100-45.csv',1,0);
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

fprintf('Horizontal error @3km high = %8.3fm\n',abs(3000/tand(A(l+1)+Broad_ang)-3000/tand(A(l)+Broad_ang)))
fprintf('Vertical error @1km away = %8.3fm\n',abs(1000*tand(A(l+1)+Broad_ang)-1000*tand(A(l)+Broad_ang)))
clear all
clc

vals=csvread('simulationResults_60_30_0.csv',1,0);
vals_c2=csvread('simulationResults_60_30_0_c4.csv',1,0);

I1 = vals(:,1:5);
I2 = vals_c2(:,1:5);

[~,i1,i2] = intersect(I1,I2,'rows');

%Just to help me output test data
i1=sort(i1);
i2=sort(i2);

A=vals(i1,7);
A_c2=vals_c2(i2,7);

errors = A_c2-A;

mean(abs(errors))
median(abs(errors))
max(abs(errors))
std(abs(errors(2:end)-errors(1:end-1)))

plot(A,errors);
xlabel('Angle theta (deg)')
ylabel('error')
title('Error over angle element 60,30 cluster size 4')
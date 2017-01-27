%% Plot results
clear all
clc
M = dlmread('data_out.txt',' ');
for i=1:size(M,1)
    mag(i)=sqrt(M(i,1)^2+M(i,2)^2);
end

sampleRate=10*10^-9;
sampleFreq=1/sampleRate;
numSamples=1024;

xAxVal = sampleFreq/numSamples;

xAxRange=0:xAxVal:xAxVal*1023;

plot(xAxRange,mag);
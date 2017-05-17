%% Initalization
clear all;
close all;
clc;

c=3*10^8;
%f=80*10^6; %I would have to look at the math here but changing f doesn't
%Seem to impact the equation at all... maybe because lamda cancels out.
%In which case it's just nice to know dx and dy.
f=80*10^9;
lamda = c/f;

dx=lamda/2;
dy=lamda/2;

k=2*pi/lamda;

syms theta p1 p2 p3 p4 p5 b x

%           n=5
%m=5;
%n=5;
%m=30;
%n=5;
%m=60;
%n=5;
%m=100;
%n=5;

%           n=30
m=5;
n=30;
%m=30;
%n=30;
%m=60;
%n=30;
%m=128;
%n=30;

%           n=60
%m=5;
%n=60;
%m=30;
%n=60;
%m=60;
%n=60;
%m=100;
%n=60;

%           n=100
%m=5;
%n=100;
%m=30;
%n=100;
%m=60;
%n=100;
%m=100;
%n=100;

%           Other tests
%m=-60;
%n=-30;
%m=45;
%n=45;
%m=-100;
%n=-100;
%m=15;
%n=15;
%m=6;
%n=5;

phi = 0;
%phi=pi/4;

%These numbers were WRONG. FML This will take forever to recalculate
%But yeah I was told the wrong numbers so fuck me.
%Below are the correct numbers and ways they are calculated.
%theta_min=20.0596;
%theta_max=85.0809;
%Broad_ang=59.0362;

%I don't like the old group nums either. I will be making my own
%theta_min=18.43;
%theta_max=87.14;
%Broad_ang=63.4;

minRange = 500;
maxRange = 3000;
minHeight = 500;
maxHeight = 10000;
idealRange = 1500;
idealHeight = 1500;

theta_min = atand(minHeight/maxRange);
theta_max = atand(maxHeight/minRange);
Broad_ang = atand(idealHeight/idealRange);

nBitRes=2^8;


%% Same thing down here but with vpa solve.
% VPA solve does not use assume function

res=[]; %Resulting angles that work
bigRes=[];  %Resulting equations for those angles when merging equations
bigP1=[];
bigP2=[];
bigP3=[];
bigP4=[];
bigP5=[];

% Determined by looping through all possible angles at small step sizes
%Same as above because someone told me how to calc these numbers
%Incorrectly this also needed to be changed. HOORAY.
%thetaD_Min =  Broad_ang - theta_max;
%thetaD_Max =  Broad_ang - theta_min;
thetaD_Max = theta_max-Broad_ang;
thetaD_Min = theta_min-Broad_ang;
delta_step=0.01;

error=0.1;

syms a er
syms m1 m2 m3 m4 m5 integer

cluser_size=4;
m=cluser_size*(floor(m/cluser_size))+(cluser_size-1)/2;
n=cluser_size*(floor(n/cluser_size))+(cluser_size-1)/2;

for thetaD = thetaD_Min:delta_step:thetaD_Max

    %Floor operator cannot be differentiated and thus vpa solve hates it.
    %Working on alternative to bound the values
    eq1 = (24*p1+8*p2+4*p3+2*p4+1*p5)/(k*(m*dx*cos(phi)+n*dy*sin(phi))) == sin((thetaD+a)*pi/180);
    %eq2 = p1-pi/nBitRes*floor(p1/(pi/nBitRes))==0+er;
    %eq2 = p1/(pi/nBitRes)==0;
    %eq2 = mod(p1,pi/nBitRes)==0+er;
    %eqOtherWay=[sin((thetaD+a)*pi/180) == (24*p1+8*p2+4*p3+2*p4+1*p5)/(k*(m*dx*cos(phi)+n*dy*sin(phi)))];
    %eqOtherWay=[eq1, eq2, eq3, eq4, eq5, eq6];
    eqOtherWay=[eq1];
   
    vpSol=vpasolve(eqOtherWay, [p1 p2 p3 p4 p5 a],[-pi/2 pi/2; -pi/2 pi/2; -pi/2 pi/2; -pi/2 pi/2; -pi/2 pi/2; -delta_step delta_step]);
    %vpSol=vpasolve(eqOtherWay, [p1 p2 p3 p4 p5]);
    thetaD
    if(size(vpSol.p1,1)>0)
        bigRes=[bigRes, vpSol];
        res=[res,thetaD]
    end
end
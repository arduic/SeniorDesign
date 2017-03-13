%% Initalization
clear all;
close all;
clc;

c=3*10^8;
f=80*10^6;
lamda = c/f;

dx=lamda/2;
dy=lamda/2;

k=2*pi/lamda;

syms theta p1 p2 p3 p4 p5 b x

m=60;
n=30;

phi = 0;
theta_min=20.0596;
theta_max=85.0809;
Broad_ang=59.0362;
%% Assumptions for the system
%Note that you can not use Mod function because of how simulink handles it.
%8bit resolution
%assume(-pi/2<=p1<=pi/2 & p1-pi/256*floor(p1/(pi/256))==0 & -pi/2<=p2<=pi/2 & p2-pi/256*floor(p2/(pi/256))==0 & -pi/2<=p3<=pi/2 & p3-pi/256*floor(p3/(pi/256))==0 & -pi/2<=p4<=pi/2 & p4-pi/256*floor(p4/(pi/256))==0 & -pi/2<=p5<=pi/2 & p5-pi/256*floor(p5/(pi/256))==0)
%6bit resolution
assume(-pi/2<=p1<=pi/2 & p1-pi/64*floor(p1/(pi/64))==0 & -pi/2<=p2<=pi/2 & p2-pi/64*floor(p2/(pi/64))==0 & -pi/2<=p3<=pi/2 & p3-pi/64*floor(p3/(pi/64))==0 & -pi/2<=p4<=pi/2 & p4-pi/64*floor(p4/(pi/64))==0 & -pi/2<=p5<=pi/2 & p5-pi/64*floor(p5/(pi/64))==0)

res=[]; %Resulting angles that work
bigRes=[];  %Resulting equations for those angles when merging equations

%% Resolution Calculation loop
% Determined by looping through all possible angles at small step sizes
thetaD_Min =  Broad_ang - theta_max;
thetaD_Max =  Broad_ang - theta_min;
delta_step=0.01;

for thetaD = thetaD_Min:delta_step:thetaD_Max
    %Equation that assosciates the Psi angles.
    %Note do not move the sin to an asin on the LHS. This will break the
    %solver due to how asin is handled
    eqns = [(24*p1+8*p2+4*p3+2*p4+1*p5)/(k*(m*dx*cos(phi)+n*dy*sin(phi))) == sin(thetaD*pi/180)];
    
    %Do not return conditions when solving, discrete solutions cannot
    %handle this and will return no solution when asked
    p1_s=solve(eqns, p1);   %Check if any solution exsists for this system for a perticular variable.
    if(size(p1_s,1)>0)
        p2_s=solve(eqns,p2);
        p3_s=solve(eqns,p3);
        p4_s=solve(eqns,p4);
        p5_s=solve(eqns,p5);
        Alleq = [p1_s==p1, p2_s==p2, p3_s==p3, p4_s==p4, p5_s==p5];
        %Check if all 5 assosciations can be held while still meeting the
        %assumptions (does not always hold)
        bigSol = solve(Alleq, [p1 p2 p3 p4 p5]);
        if(size(bigSol.p1,1)>0)
            thetaD  %Store the results and print them
            res=[res,thetaD];
            bigRes=[bigRes,bigSol.p1];
        end
    end
end
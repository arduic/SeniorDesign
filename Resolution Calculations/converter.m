%% Primary stuff
finalRes=[];
bigResRefined=[];

for sols=1:size(bigRes,2)
    bigRes(sols).p1 = pi/nBitRes*round((bigRes(sols).p1 + pi/2)/pi*nBitRes) - pi/2;
    bigRes(sols).p1 = max(min(bigRes(sols).p1, pi / 2), -pi/2);

    bigRes(sols).p2 = pi/nBitRes*round((bigRes(sols).p2 + pi/2)/pi*nBitRes) - pi/2;
    bigRes(sols).p2 = max(min(bigRes(sols).p2, pi / 2), -pi/2);

    bigRes(sols).p3 = pi/nBitRes*round((bigRes(sols).p3 + pi/2)/pi*nBitRes) - pi/2;
    bigRes(sols).p3 = max(min(bigRes(sols).p3, pi / 2), -pi/2);

    bigRes(sols).p4 = pi/nBitRes*round((bigRes(sols).p4 + pi/2)/pi*nBitRes) - pi/2;
    bigRes(sols).p4 = max(min(bigRes(sols).p4, pi / 2), -pi/2);

    bigRes(sols).p5 = pi/nBitRes*round((bigRes(sols).p5 + pi/2)/pi*nBitRes) - pi/2;
    bigRes(sols).p5 = max(min(bigRes(sols).p5, pi / 2), -pi/2);
    
    eqX = (24*bigRes(sols).p1+8*bigRes(sols).p2+4*bigRes(sols).p3+2*bigRes(sols).p4+1*bigRes(sols).p5)/(k*(m*dx*cos(phi)+n*dy*sin(phi))) == sin((res(sols)+a)*pi/180);
    
    newVPSol=vpasolve(eqX,a,[-delta_step delta_step]);
    if(size(newVPSol,1)>0)
        sols
        finalRes=[finalRes, res(sols)+newVPSol];
        bigResRefined=[bigResRefined,bigRes(sols)];
    end
end

%% Secondary stuff
cleanAngles=[];
cleanPs=struct('p1',{},'p2',{},'p3',{},'p4',{},'p5',{},'a',{});

cleanAngles(1)=finalRes(1)
cleanPs(1)=bigResRefined(1)

for sols=2:size(finalRes,2)
    if(abs(finalRes(sols)-finalRes(sols-1))>0.0000001)
        sols
        cleanAngles=[cleanAngles, finalRes(sols)];
        cleanPs=[cleanPs, bigResRefined(sols)];
    end
end

%% Final bit
clearvars -except cleanAngles cleanPs
f=double(cleanAngles);
c=struct2cell(cleanPs);
a=[c{:}];
b=double(a);
s=[b(1:6:end); b(2:6:end); b(3:6:end); b(4:6:end); b(5:6:end); b(6:6:end); f]';
ds=mat2dataset(s);
ds.Properties.VarNames{1}='p1';
ds.Properties.VarNames{2}='p2';
ds.Properties.VarNames{3}='p3';
ds.Properties.VarNames{4}='p4';
ds.Properties.VarNames{5}='p5';
ds.Properties.VarNames{6}='a';
ds.Properties.VarNames{7}='ang';
export(ds,'File','simulationResults.csv','Delimiter',',')
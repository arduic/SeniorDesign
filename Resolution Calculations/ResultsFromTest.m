diffs=res(2:end)-res(1:end-1);  %Get delta of angles
B = diffs > 0.010001;   %Remove ones where there was no gap

realDiffs = diffs(B);   %Only look at those without gaps

mean(realDiffs) %Calc standard stuff
median(realDiffs)
max(realDiffs)
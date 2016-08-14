%
% V4

% Upper right  (V4_LH_loc12)
% low alone %stimvol 1 & 2
stimvol_V4{1}{1} = cat(2,d.stimvol{1},d.stimvol{2});
stimvol_V4{1}{1} = sort(stimvol_V4{1}{1});
% high alone - stimvol 5 & 6
stimvol_V4{1}{2} = cat(2,d.stimvol{5},d.stimvol{6});
stimvol_V4{1}{2} = sort(stimvol_V4{1}{2});
% together - 9 & 10
stimvol_V4{1}{3} = cat(2,d.stimvol{9},d.stimvol{10});
stimvol_V4{1}{3} = sort(stimvol_V4{1}{3});

% Lower left  (V4_RH_loc34)
% low alone %stimvol 3 & 4
stimvol_V4{2}{1} = cat(2,d.stimvol{3},d.stimvol{4});
stimvol_V4{2}{1} = sort(stimvol_V4{2}{1});
% high alone - stimvol 7 & 8
stimvol_V4{2}{2} = cat(2,d.stimvol{7},d.stimvol{8});
stimvol_V4{2}{2} = sort(stimvol_V4{2}{2});
% together - 11 & 12
stimvol_V4{2}{3} = cat(2,d.stimvol{11},d.stimvol{12});
stimvol_V4{2}{3} = sort(stimvol_V4{2}{3});

roiV4{1} = loadROITSeries(view,'V4_LH_er');
roiV4{2} = loadROITSeries(view,'V4_RH_er');

v4cutoffr2= .2;
ercutoff = .1;
scan = 1;
d.r2 = analysis.overlays(1).data{scan};
n=0;
for l = 1:2
    for voxnum = 1:roiV4{l}.n
        % get coordinates
        x = roiV4{l}.scanCoords(1,voxnum);
        y = roiV4{l}.scanCoords(2,voxnum);
        s = roiV4{l}.scanCoords(3,voxnum);
        
        % based on r2 from cor analysis
%         if corAnal.overlays(1).data{1}(x,y,s) >= v4cutoffr2
        if d.r2(x,y,s) >= ercutoff
            n = n+1;
            tseriesROIV4{l}(n,:) = roiV4{l}.tSeries(voxnum,:);
        end
    end
end

% concat tSeries for V4
for l = 1:2
    tseriesV4{l} = mean(tseriesROIV4{l});
end
[tSeriesOutV4, stimvolOutV4, concatInfoOutV4] = concatRuns(tseriesV4,{stimvol_V4{1}, stimvol_V4{2}},{concatInfo{1}, concatInfo{2}});
dV4 = fitTimecourse(tSeriesOutV4,stimvolOutV4,framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1');


dlV4 = fitTimecourse(mean(tseriesROIV4{1}), stimvol_V4{1},framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1');
drV4 = fitTimecourse(mean(tseriesROIV4{2}), stimvol_V4{2},framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1');


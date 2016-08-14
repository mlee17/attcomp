% concatRuns for V1
% average across voxels first in each location
% create stimvols for different locations separately

loc = {'loc1','loc2','loc3','loc4'};

% create stimvols for different locations
whichcond = [1,5,9,10; 2,6,10,9; 3,7,11,12; 4,8,12,11];
stimNames = {'low alone','high alone', 'low with high', 'high with low'};


framePeriod = .5;
for l = 1:length(loc)
    stimvol{l} = d.stimvol(whichcond(l,:));
end

% get concat Info
concatInfo = viewGet(view,'concatInfo',1,4);
concatInfo = repmat({concatInfo},1,length(loc));

% concat tSeries for V1
for l = 1:length(loc)
    tseriesV1{l} = mean(tseriesROI{1}{l});
end

[tSeriesOutV1, stimvolOutV1, concatInfoOutV1] = concatRuns(tseriesV1,stimvol,concatInfo);
dV1 = fitTimecourse(tSeriesOutV1,stimvolOutV1,framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1', 'hdrlen=25');

% for V2
% concat tSeries for V2
for l = 1:length(loc)
    tseriesV2{l} = mean(tseriesROI{2}{l});
end
[tSeriesOutV2, stimvolOutV2, concatInfoOutV2] = concatRuns(tseriesV2,stimvol,concatInfo);
dV2 = fitTimecourse(tSeriesOutV2,stimvolOutV2,framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1','hdrlen=25');

% for V3
% concat tSeries for V3
for l = 1:length(loc)
    tseriesV3{l} = mean(tseriesROI{3}{l});
end
[tSeriesOutV3, stimvolOutV3, concatInfoOutV3] = concatRuns(tseriesV3,stimvol,concatInfo);
dV3 = fitTimecourse(tSeriesOutV3,stimvolOutV3,framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1','hdrlen=25');

% for V1-3
[tSeriesOutAll, stimvolOutAll, concatInfoOutAll] = concatRuns({tSeriesOutV1, tSeriesOutV2, tSeriesOutV3}, ...
    {stimvolOutV1, stimvolOutV2, stimvolOutV3}, {concatInfoOutV1, concatInfoOutV2, concatInfoOutV3});
dAll = fitTimecourse(tSeriesOutAll,stimvolOutAll,framePeriod,'fitType=deconv','amplitudeType=fit2','displayFit=1','hdrlen=25');






%%

  plotFit(titlestr,d.deconv,d.amplitude,d.ehdr,d.time);
  
%%%%%%%%%%%%%%%%%
%%   plotFit   %%
%%%%%%%%%%%%%%%%%
function plotFit(titlestr,deconv,amplitude,fitehdr,fittime,whichOne,voxNum)

if ieNotDefined('fittime'),fittime=deconv.time;end
if ieNotDefined('whichOne'),whichOne = 1:deconv.nhdr;end
if ieNotDefined('voxNum'),voxNum = 1;end
if ndims(deconv.ehdr) == 3
  titlestr = sprintf('%s (Voxel %i)',titlestr,voxNum);
end
cla;
legendStr = {};legendSymbol = {}; r2 = [];
for i = whichOne
  color = getSmoothColor(find(i==whichOne),length(whichOne),'hsv');
  if ndims(deconv.ehdr) == 3
    % many voxels, choose the right voxel to plot
    dispData = squeeze(deconv.ehdr(voxNum,i,:));
    dispDataSTE = squeeze(deconv.ehdrste(voxNum,i,:));
    dispFitData = squeeze(fitehdr(voxNum,i,:));
    dispAmp = amplitude(voxNum,i);
  else
    % single voxel
    dispData = deconv.ehdr(i,:);
    dispDataSTE = deconv.ehdrste(i,:);
    dispFitData = fitehdr(i,:);
    dispAmp = amplitude(i);
  end
  % plot
  myerrorbar(deconv.time,dispData,'yError',dispDataSTE,'Symbol','o','MarkerFaceColor',color,'MarkerEdgeColor','w');
  plot(fittime,dispFitData,'-','Color',color);
  % legend
  legendStr{end+1} = sprintf('%f',dispAmp);
  legendSymbol{end+1} = {'ko' color};
  % compute the fit r2
  fitMatch = interp1(fittime,dispFitData,deconv.time);
  r2(end+1) = 1 - var(dispData(:)-fitMatch(:))/var(dispData(:));
end
mylegend(legendStr,legendSymbol);
xlabel('time (sec)');
ylabel('response magnitude');
title(sprintf('%s (r2=%s)',titlestr,num2str(r2,'%0.2f ')));
drawnow


d_v1loc1 = fitTimecourse(mean(tseriesROI{1}{1}),stimvol{1},.5,'fitType=deconv','hdrlen=25');      


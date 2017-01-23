function [roi, tseriesROI] = eventRelatedROI(view, varargin)%,overlayNum,scan,x,y,s,roi)
% eventRelatedPlot.m

eval(evalargs(varargin,0,0,{'V1','V2','V3'}));
scan = 1;
if isempty(varargin)
    area = {'V1','V2','V3'};
elseif exist('V1','var') || exist('V2','var') || exist('V3','var')
    area = varargin;
else
    disp(sprintf('invalid ROI name entered'))
    return
end

% % check arguments
% if ~any(nargin == [1:7])
%   help eventRelatedPlot
%   return
% end

if ieNotDefined('view')
    view = newView;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Localizer info
view = viewSet(view, 'currentGroup', 'Averages');
analysisFile_loc = dir('Averages/corAnal/corAnal.mat');

% get the analysis structure
corAnal = viewGet(view,'analysis');
if ~isfield(corAnal,'overlays') || isempty(corAnal.overlays)
  disp(sprintf('no analysis loaded for Averages group. loading analysis...'));
  view = loadAnalysis(view, ['corAnal/', analysisFile_loc.name]);
    corAnal = viewGet(view,'analysis');
end

% r2 values
corR2 = corAnal.overlays(1).data{1};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER analysis
view = viewSet(view, 'currentGroup', 'Concatenation');
analysisFile_unatt = dir('Concatenation/erAnal/erAnal_unattended.mat'); %_seg1.mat');
% analysisFile_att = dir('Concatenation/erAnal/erAnal.mat');

% get the analysis structure
analysis = viewGet(view,'analysis');
if ~isfield(analysis,'d') || (length(analysis.d) < scan) || isempty(analysis.d)
  disp(sprintf('(eventRelatedPlot) Event related not for scan %i',scan));
  
  view = loadAnalysis(view, ['erAnal/' analysisFile_unatt.name]);
  analysis = viewGet(view,'analysis');

end
d = analysis.d{scan};
if isempty(d)
  mrWarnDlg(sprintf('(eventRelatedPlot) Could not find d structure for scan %i. Has eventRelated been run for this scan?',scan));
  return
end
% d.r2 = analysis.overlays(1).data{scan};

if isempty(d)
  disp('No analysis');
  return
end


% get cutoff value
% cutoffr2 = viewGet(view,'overlayMin');
cutoffr2= .2; % for cor analysis!!!!!
v4cutoffr2 = .1; % applying more liberal threshold for v4

hdrlen = d.hdrlen;
% check if this is a glm analysis
% then we scale the hrd 
if isfield(d, 'hrf')
%    hdr = hdr*(d.hrf'-mean(d.hrf));
    hdr = hdr*d.hrf';
    hdrlen = size(d.hrf,1);
end
  time = d.tr/2:d.tr:(hdrlen*d.tr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   ROI mean response - run ER analysis   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gEventRelatedPlot;
% make a lighter view
v = newView;
v = viewSet(v,'curGroup',viewGet(view,'curGroup'));
v = viewSet(v,'curScan',viewGet(view,'curScan'));
gEventRelatedPlot.v = v;

gEventRelatedPlot.scan = scan;
% gEventRelatedPlot.vox = [x y s];
gEventRelatedPlot.d = d;
gEventRelatedPlot.d.ehdr = [];
gEventRelatedPlot.d.ehdrste = [];
gEventRelatedPlot.plotTSeriesHandle = [];
gEventRelatedPlot.computeErrorBarsHandle = [];
% gEventRelatedPlot.roi = roi;
gEventRelatedPlot.time = time;
gEventRelatedPlot.cutoffr2 = cutoffr2;
gEventRelatedPlot.computingErrorBars = 0;
gEventRelatedPlot.loadingTimecourse = 0;

% % set the delete function, so that we can delete the global we create
% set(fignum,'DeleteFcn',@eventRelatedCloseWindow);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if there is an roi at this voxel
% then plot mean response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for roinum = 1:length(ROIs)
% %   subplot(2,2,4);
%     subplot(2,2,roinum)
%   ehdr = [];
%   roin = 0;
%   % first go for the quick and dirty way, which is
%   % to load up the computed hemodynamic responses
%   % and average them. 
%   disppercent(-inf,'(eventRelatedPlot) Computing mean hdr');
%   
% %   corAnal.overlays(1).data{1}(roi{1}.scanCoords(1,1), roi{1}.scanCoords(2,1), roi{1}.scanCoords(3,1))
%   
% %   for voxnum = 1:size(roi{roinum}.scanCoords,2)
% %     disppercent(voxnum,size(roi{roinum}.scanCoords,2));
% %     x = roi{roinum}.scanCoords(1,voxnum);
% %     y = roi{roinum}.scanCoords(2,voxnum);
% %     s = roi{roinum}.scanCoords(3,voxnum);
% %     %based on r2 from cor analysis
% %     if corAnal.overlays(1).data{1}(x,y,s) >= cutoffr2 %d.r2(x,y,s) >= cutoffr2
% %       roin = roin+1;
% %       [ehdr(roin,:,:) time] = gethdr(d,x,y,s);
% %       % if there is a peak field, calculate average peak
% %       if isfield(d,'peak')
% % 	for i = 1:d.nhdr
% % 	  amp(i,roin) = d.peak.amp(x,y,s,i);
% % 	end
% %       end
% %     end
% %     disppercent(voxnum/size(roi{roinum}.scanCoords,2));
% %   end
%   
%   whichcond = [roinum, 4+roinum, 8+roinum];
%   % plot the average of the ehdrs that beat the r2 cutoff
%   if roin
%     plotEhdr(whichcond,time,shiftdim(mean(ehdr),1));
%   end
%   title(sprintf('%s (n=%i/%i)',roi{roinum}.name,roin,size(roi{roinum}.scanCoords,2)),'Interpreter','none');
%   % create a legend (only if peaks exist) to display mean amplitudes
%   if isfield(d,'peak')
%     for i = 1:length(whichcond) %for i = 1:d.nhdr
%       % get the stimulus name
%       if isfield(d,'stimNames')
% 	stimNames{i} = d.stimNames{whichcond(i)};
%       else
% 	stimNames{i} = '';
%       end
%       % and now append the peak info
%       stimNames{i} = sprintf('%s: median=%0.2f',stimNames{whichcond(i)},median(amp(whichcond(i),:)));
%     end
%     lhandle = legend(stimNames);
%     set(lhandle,'Interpreter','none');
%   end
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
loc = {'loc1','loc2','loc3','loc4'};

whichcond = [1,5,9,10; 2,6,10,9; 3,7,11,12; 4,8,12,11];
stimNames = {'low alone','high alone', 'low with high', 'high with low'};

% phase range (localizer) loc 1 - 4
phRange = [5.0 5.8; 0.7 1.6; 2.2 3.0; 3.5 4.2];

% % select the window to plot into
% fignum = figure;
% % turn off menu/title etc.
% set(fignum,'NumberTitle','off');
% set(fignum,'Name','eventRelatedPlot');
        
% % set roi coords
% for roinum = 1:length(ROIs)
%   % get scan coordinates
%   roi{roinum}.scanCoords = getROICoordinates(view,ROIs{roinum});
%   roin(roinum) = size(roi{roinum}.scanCoords,2);
% end

% COMPUTE ERROR BARS

disp(sprintf('(eventRelatedPlot) Computing error bars over stimulus repetitions (i.e. averaging together all voxels that meet the r2 cutoff to form a single timecourse and then computing error bars using the inverse of the design covariance matrix)'));
gEventRelatedPlot.computingErrorBars = 1;
v = gEventRelatedPlot.v;
% roi = gEventRelatedPlot.roi;
d = gEventRelatedPlot.d;
cutoffr2 = gEventRelatedPlot.cutoffr2;

for a = 1:length(area)
    figure(a);
    set(a,'NumberTitle','off');
    set(a,'Name',['eventRelated: ',area{a}]);

for locnum = 1:length(loc)
%   subplot(2,2,4);
    subplot(2,2,locnum)
  ehdr = [];
  roin = 0;
  er=[];
  meanTimecourse = [];

% get the time series
roi{a}{locnum} = loadROITSeries(v,[area{a},'_',loc{locnum}]);

n = 0;
for voxnum = 1:roi{a}{locnum}.n
  % get coordinates
  x = roi{a}{locnum}.scanCoords(1,voxnum);
  y = roi{a}{locnum}.scanCoords(2,voxnum);
  s = roi{a}{locnum}.scanCoords(3,voxnum);
  
  %based on r2 & phase from cor analysis
  if corAnal.overlays(1).data{1}(x,y,s) >= cutoffr2 && (corAnal.overlays(3).data{1}(x,y,s) >= phRange(locnum,1) && corAnal.overlays(3).data{1}(x,y,s) <= phRange(locnum,2)) %d.r2(x,y,s) > cutoffr2
    n = n+1;
    tseriesROI{a}{locnum}(n,:) = roi{a}{locnum}.tSeries(voxnum,:);
  end
  
end

yowsa = tseriesROI{a}{locnum};
if n == 0
  disp(sprintf('(eventRelatedPlot) No voxels met r2 > %0.3f',cutoffr2));
elseif n > 1
  meanTimecourse = mean(tseriesROI{a}{locnum});
end

% compute the event related analysis and the error bars
er = getr2timecourse(meanTimecourse,d.nhdr,d.hdrlen,d.scm,d.tr);

% plot them
plotEhdr(whichcond(locnum,:), er.time,er.ehdr,er.ehdrste);

title(sprintf('%s (n=%i/%i)',roi{a}{locnum}.name,n,size(roi{a}{locnum}.scanCoords,2)),'Interpreter','none');

  % create a legend (only if peaks exist) to display mean amplitudes
%   if isfield(d,'peak')
%     for i = 1:length(whichcond(roinum,:)) %for i = 1:d.nhdr
%       % get the stimulus name
%       if isfield(d,'stimNames')
% 	stimNames{i} = d.stimNames{whichcond(roinum,i)};
%       else
% 	stimNames{i} = '';
%       end
%       % and now append the peak info
% %       stimNames{whichcond(i)} = sprintf('%s',stimNames{whichcond(i)});%,median(amp(whichcond(i),:)));
%     end
    lhandle = legend(stimNames);
    set(lhandle,'Interpreter','none');
%   end

end
end

%% get area means (collapse across different positions)

% [meanTimecourse, allROImean] = computeMeanROI(d,tseriesROI);
% figure
% set(gcf,'NumberTitle','off');
% set(gcf,'Name','eventRelated: mean time course');
% for a = 1:length(area)
%     er = [];
%     subplot(2,2,a)
%     % compute the event related analysis and the error bars
%     er = getr2timecourse(meanTimecourse{a}, d.nhdr,d.hdrlen,d.scm,d.tr);
%     
%     % plot
%     plotEhdr(
% end


%%%%%%%%%%%%%%%%%%%%%%%%%
%% function to plot ehdr
%%%%%%%%%%%%%%%%%%%%%%%%%
function plotEhdr(whichcond, time,ehdr,ehdrste,lineSymbol)

% whether to plot the line inbetween points or not
if ~exist('lineSymbol','var'),lineSymbol = '-';end

brewer = brewermap(4,'RdBu');
stimNames = {'low alone','high alone', 'low with high', 'high with low'};
colors = [brewer(4,:); brewer(1,:); brewer(3,:); brewer(2,:)];
symbols = [1,2,1,2];
% display ehdr
for i = 1:length(whichcond)
  if ieNotDefined('ehdrste')
    h=plot(time,ehdr(whichcond(i),:),getsymbol(symbols(i),lineSymbol),'Color', colors(i,:),'MarkerSize',7.5, 'LineWidth',1.5);  %getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
  else
    h=errorbar(time,ehdr(whichcond(i),:),ehdrste(whichcond(i),:),ehdrste(whichcond(i),:),getsymbol(symbols(i),lineSymbol),'Color', colors(i,:),'MarkerSize',7);%getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
  end
  set(h,'MarkerFaceColor',colors(i,:));
  hold on
end 

% % and display ehdr
% for i = 1:size(ehdr,1)
%   if ieNotDefined('ehdrste')
%     h=plot(time,ehdr(i,:),getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
%   else
%     h=errorbar(time,ehdr(i,:),ehdrste(i,:),ehdrste(i,:),getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
%   end
%   set(h,'MarkerFaceColor',getcolor(i));
%   hold on
% end
xlabel('Time (sec)');
ylabel('% Signal change');


function [roi, tseriesROI, stimvolCat, d, dMean, dAll, dV4]=erROI(view, varname, hdrlen, scan, varargin)

% scan = 1;
getArgs(varargin);
if isempty(varargin)
    area = {'V1','V2','V3'};
elseif exist('V1','var') || exist('V2','var') || exist('V3','var')
    area = varargin;
else
    disp(sprintf('invalid ROI names entered'))
    return
end

if ~isstr(varname)
    warning('The input varname must be string')
    return
end

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

% % r2 values
%loading in corAnal from the previous session
% load('corAnal.mat');
corR2 = corAnal.overlays(1).data{1};

% get cutoff value
% cutoffr2 = viewGet(view,'overlayMin');
cutoffr2= .2; % for cor analysis!!!!!
% phase range (localizer) loc 1 - 4
% phRange = [5.0 5.8; 0.7 1.6; 2.2 3.0; 3.5 4.2];
phRange = [3.74 6.28; 0.6 3.34; 0.6 3.34; 3.74 6.28];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER analysis
view = viewSet(view, 'currentGroup', 'Concatenation');
view = viewSet(view,'currentScan',scan);
groupnum = viewGet(view,'groupnum','Concatenation');
concatInfo = viewGet(view,'concatInfo',scan,groupnum);

tr = viewGet(view,'tr', scan, groupnum);
framePeriod = viewGet(view,'framePeriod',scan,groupnum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V1 - V3: four quadrants
loc = {'loc1','loc2','loc3','loc4'};
if strcmp(varname, 'unatt') || strcmp(varname, 'stimonly')
    stimNames = {'low alone', 'low with high', 'high alone', 'high with low','low outside', 'high outside'};
else
    stimNames = {'low attended', 'low unattended', 'high attended', 'high unattended'};
    
end

stimvolCat = {};
for locnum = 1:length(loc)
    curVarname = sprintf('%s%d',varname,locnum);

    [stimvol, stimNamesOrg, var] = getStimvol(view, curVarname, 'taskNum=1','phaseNum=1', 'segmentNum=2');
    
        if length(stimvol) ==4
         curStimvol = stimvol;%stimvol((locnum-1)*4+1:(locnum-1)*4+4);
        else
            curStimvol = stimvol(2:5);
        end
        stimvolCat{locnum} = curStimvol;
end
for locnum = 1:length(loc)
    if mod(locnum,2) == 1 %loc 1 and 3
        stimvolCat{locnum}{5} = stimvolCat{locnum+1}{1};
        stimvolCat{locnum}{6} = stimvolCat{locnum+1}{3};
    else
        stimvolCat{locnum}{5} = stimvolCat{locnum-1}{1};
        stimvolCat{locnum}{6} = stimvolCat{locnum-1}{3};
    end
end
    

% for each quadrants in each visual area.....
% then average across quadrants....
for a = 1:length(area)

    figure(a+5);
    set(gcf,'NumberTitle','off');
    set(gcf,'Name',['eventRelated: ',area{a}]);
    for locnum = 1:length(loc)

        meanTimecourse = [];
        % get the time series
        roi{a}{locnum} = loadROITSeries(view,[area{a},'_',loc{locnum}]);
    
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
        if n == 0
            disp(sprintf('(eventRelatedPlot) No voxels met r2 > %0.3f',cutoffr2));
        elseif n > 1
            meanTimecourse = mean(tseriesROI{a}{locnum});
        end
        d{a}{locnum} = fitTimecourse(meanTimecourse,stimvolCat{locnum},framePeriod,'concatInfo', concatInfo, ...
            'fitType=deconv','amplitudeType=fit2','displayFit=1', 'hdrlen', hdrlen);
        
        figure(a+5)
        subplot(2,2,locnum)
        plotEhdr(d{a}{locnum}.deconv.time, d{a}{locnum}.deconv.ehdr, d{a}{locnum}.deconv.ehdrste);
        title(sprintf('%s (n=%i/%i)',roi{a}{locnum}.name,n,size(roi{a}{locnum}.scanCoords,2)),'Interpreter','none');
        lhandle = legend(stimNames);
        set(lhandle,'Interpreter','none');
        set(lhandle, 'FontSize', 8);
        box off;
%           plotFit(titlestr,d.deconv,d.amplitude,d.ehdr,d.time);
%           plotEhdr(er.time,er.ehdr,er.ehdrste);
    end

end

concatInfoCat = repmat({concatInfo},1,length(loc));

for a = 1:length(area)
for l = 1:length(loc)
    tseriesMean{a}{l} = mean(tseriesROI{a}{l});
end
[tSeriesOut{a}, stimvolOut{a}, concatInfoOut{a}] = concatRuns(tseriesMean{a},stimvolCat,concatInfoCat);

dMean{a} = fitTimecourse(tSeriesOut{a}, stimvolOut{a},framePeriod, 'concatInfo', concatInfoOut{a},... 
                    'fitType=deconv','amplitudeType=fit2','displayFit=1', 'hdrlen', hdrlen);
 figure;
         plotEhdr(dMean{a}.deconv.time, dMean{a}.deconv.ehdr, dMean{a}.deconv.ehdrste);
         lhandle = legend(stimNames);
        set(lhandle,'Interpreter','none');
        set(lhandle, 'FontSize', 9);
        box off;
        % title / vox num
               
end

% for V1-3
[tSeriesOutAll, stimvolOutAll, concatInfoOutAll] = concatRuns({tSeriesOut{1}, tSeriesOut{2}, tSeriesOut{3}}, ...
    {stimvolOut{1}, stimvolOut{2}, stimvolOut{3}}, {concatInfoOut{1}, concatInfoOut{1}, concatInfoOut{1}});
dAll = fitTimecourse(tSeriesOutAll,stimvolOutAll,framePeriod,'concatInfo', concatInfoOutAll, ...
    'fitType=deconv','amplitudeType=fit2','displayFit=1', 'hdrlen', hdrlen);
 figure;
         plotEhdr(dAll.deconv.time, dAll.deconv.ehdr, dAll.deconv.ehdrste);
        lhandle = legend(stimNames);
        set(lhandle,'Interpreter','none');
        set(lhandle, 'FontSize', 9);
        box off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% V4
roiV4{1} = loadROITSeries(view,'V4_LH_loc12');
roiV4{2} = loadROITSeries(view,'V4_RH_loc34');
v4cutoffr2= .2;
n=0;
for a = 1:2
    for voxnum = 1:roiV4{a}.n
        % get coordinates
        x = roiV4{a}.scanCoords(1,voxnum);
        y = roiV4{a}.scanCoords(2,voxnum);
        s = roiV4{a}.scanCoords(3,voxnum);
        
        % based on r2 from cor analysis
        if corAnal.overlays(1).data{1}(x,y,s) >= v4cutoffr2

            n = n+1;
            tseriesROIV4{a}(n,:) = roiV4{a}.tSeries(voxnum,:);
        end
    end
end
%stimvol
for a = 1:2
% Upper right  (V4_LH_loc12)
% low alone
stimvolV4{a}{1} = stimvolCat{2*a-1}{1};
stimvolV4{a}{2} = stimvolCat{2*a}{1};
%cat(2,stimvolCat{1}{1}, stimvolCat{2}{1});
% high alone
stimvolV4{a}{3} = stimvolCat{2*a-1}{3};
stimvolV4{a}{4} = stimvolCat{2*a}{3};
% low + high
stimvolV4{a}{5} = stimvolCat{2*a-1}{2};
stimvolV4{a}{6} = stimvolCat{2*a-1}{4};

%low alone, high alone, low+high
for stim = 1:3
    stimvolV4_pooled{a}{stim} = cat(2, stimvolV4{a}{2*stim-1}, stimvolV4{a}{2*stim});
    stimvolV4_pooled{a}{stim} = sort(stimvolV4_pooled{a}{stim});
end

% separately for different stim config (locations...)
dV4{a} = fitTimecourse(mean(tseriesROIV4{a}),stimvolV4{a},framePeriod,'concatInfo', concatInfo, ...
            'fitType=deconv','amplitudeType=fit2', 'displayFit=1', 'hdrlen', hdrlen); 
        figure;
    	set(gcf,'NumberTitle','off');
        if a == 1
            set(gcf,'Name','eventRelated: left V4');
        else
            set(gcf,'Name','eventRelated: right V4');
        end
               
        brewer = brewermap(6,'*RdBu');
        colors = [brewer(1,:); brewer(6,:)];
        for p = 1:2
            subplot(2,2,p)
            for i = 1:2
            h = errorbar(dV4{a}.deconv.time, dV4{a}.deconv.ehdr(p+2*(i-1),:), dV4{a}.deconv.ehdrste(p+2*(i-1),:), 'o-', 'Color',colors(i,:), 'MarkerSize',6, 'MarkerEdgeColor','w');
            set(h,'MarkerFaceColor', colors(i,:))
            hold on
            end
            xlabel('Time (sec)');
            ylabel('% Signal change');
            lhandle= legend({'low alone', 'high alone'});
            set(lhandle,'Interpreter','none');
            set(lhandle, 'FontSize', 8.5);
            box off;
        end
        for p = 1:2
            subplot(2,2,2+p)
            h = errorbar(dV4{a}.deconv.time, dV4{a}.deconv.ehdr(4+p,:), dV4{a}.deconv.ehdrste(4+p,:), 'o-', 'Color',[.7,.7,.7], 'MarkerSize',6, 'MarkerEdgeColor','w');
            set(h,'MarkerFaceColor', [.7,.7,.7])
            xlabel('Time (sec)');
            ylabel('% Signal change');
            lhandle= legend('low + high');
            set(lhandle,'Interpreter','none');
            set(lhandle, 'FontSize', 8.5);
            box off;
        end
        
 % average across different stim config
 dV4_locPooled{a} = fitTimecourse(mean(tseriesROIV4{a}), stimvolV4_pooled{a}, framePeriod, 'concatInfo', concatInfo,...
       'fitType=deconv','amplitudeType=fit2', 'displayFit=1', 'hdrlen', hdrlen);
 figure;
 set(gcf,'NumberTitle','off');
        if a == 1
            set(gcf,'Name','eventRelated: left V4 pooled');
        else
            set(gcf,'Name','eventRelated: right V4 pooled');
        end
        plotEhdr(dV4_locPooled{a}.deconv.time, dV4_locPooled{a}.deconv.ehdr, dV4_locPooled{a}.deconv.ehdrste);
        lhandle= legend({'low alone', 'high alone', 'low+high'});
        set(lhandle,'Interpreter','none');
        set(lhandle, 'FontSize', 9);
        box off;
end

%left V4 ave
%right V4 ave
%left and right both

%%%%%%%%%%%%%%%%%%%%%%%%%
%% function to plot ehdr
%%%%%%%%%%%%%%%%%%%%%%%%%
function plotEhdr(time,ehdr,ehdrste,lineSymbol)

% whether to plot the line inbetween points or not
if ~exist('lineSymbol','var'),lineSymbol = '-';end

brewer = brewermap(8,'*RdBu');
if size(ehdr,1) == 6
% colors = [brewer(1,:); brewer(2,:); brewer(4,:); brewer(3,:)];
colors = [brewer(1,:); brewer(2,:); brewer(8,:); brewer(7,:); brewer(3,:); brewer(6,:)];
symbols = [1,1,1,1,2,2];
% getsymbol(symbols(i),lineSymbol)
elseif size(ehdr,1) == 3
    colors = [brewer(1,:); brewer(8,:); .5,.5,.5];
    symbols = [1,1,1];
end

% display ehdr
for i = 1:size(ehdr,1)
  if ieNotDefined('ehdrste')
    h=plot(time,ehdr(i,:),getsymbol(symbols(i),lineSymbol),'Color', colors(i,:),'MarkerSize',6, 'LineWidth',1.5);  %getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
  else
    h=errorbar(time,ehdr(i,:),ehdrste(i,:),ehdrste(i,:),getsymbol(symbols(i),lineSymbol),'Color', colors(i,:),'MarkerSize',6,'MarkerEdgeColor','w');%getcolor(i,getsymbol(i,lineSymbol)),'MarkerSize',8);
  end
  set(h,'MarkerFaceColor',colors(i,:));
  hold on
end 

xlabel('Time (sec)');
ylabel('% Signal change');
% getsymbol(symbols(i),lineSymbol)
% ['o',lineSymbol]
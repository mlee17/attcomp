function eventRelatedAtt(view, session,varargin)
scan = 1;
session = 's31620160720';
datadir = sprintf('~/data/attentionComp/%s', session);

if ieNotDefined('view')
    view = newView;
end

area = {'V1','V2','V3'}; % and V4

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
analysisFile_att = dir('Concatenation/erAnal/erAnal_attended.mat');
view = loadAnalysis(view, ['erAnal/' analysisFile_att.name]);
analysis_att = viewGet(view,'analysis');
d_att = analysis_att.d{scan};

load([datadir,'/roiTseries.mat']);
d_unatt = d;

cutoffr2 = .2;
V4ercutoff = .1;

hdrlen=d.hdrlen;
% check if this is a glm analysis
% then we scale the hrd 
if isfield(d, 'hrf')
%    hdr = hdr*(d.hrf'-mean(d.hrf));
    hdr = hdr*d.hrf';
    hdrlen = size(d.hrf,1);
end
  time = d.tr/2:d.tr:(hdrlen*d.tr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc = {'loc1','loc2','loc3','loc4'};

whichcond_unatt = [1,5,9,10; 2,6,10,9; 3,7,11,12; 4,8,12,11];
stimNames_unatt = {'low alone','high alone', 'low with high', 'high with low'};

%[11 12 13 14  21 22 23 24]
whichcond_att = [1,5; 2,6; 3,7; 4,8];
stimNames_att = {'attend Low', 'attend High'};

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
  meantimecourse = [];
  
  meanTimecourse = mean(tseriesROI{a}{locnum});
  
  % compute the event related analysis and the error bars
    er = getr2timecourse(meanTimecourse,d_att.nhdr,d_att.hdrlen,d_att.scm,d_att.tr);
% plot them


plotEhdr(whichcond_att(locnum,:), er.time,er.ehdr,er.ehdrste);

% title(sprintf('%s (n=%i/%i)',roi{a}{locnum}.name,n,size(roi{a}{locnum}.scanCoords,2)),'Interpreter','none');
title(sprintf('%s',roi{a}{locnum}.name),'Interpreter','none');

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
    lhandle = legend(stimNames_att);
    set(lhandle,'Interpreter','none');

end

    
end

function plotEhdr(whichcond, time,ehdr,ehdrste,lineSymbol)

% whether to plot the line inbetween points or not
if ~exist('lineSymbol','var'),lineSymbol = '-';end

if length(whichcond) == 4
brewer = brewermap(4,'RdBu');
stimNames = {'low alone','high alone', 'low with high', 'high with low'};
colors = [brewer(4,:); brewer(1,:); brewer(3,:); brewer(2,:)];
symbols = [1,2,1,2];
else
brewer = brewermap(4,'RdBu');
stimNames={'attend Low','attend High'};
colors = [brewer(4,:); brewer(1,:)];
symbols= [1,2];
end

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


% function   ehdr, ehdrste, time, stimvol, stimName
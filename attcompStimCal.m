function attcompStimCal(session)
% creating stimvol files

% session = 's31620160720';
datadir = '~/data/attentionComp/';
stimdir = sprintf(['%s', session, '/Etc/'],datadir);
stimfiles = dir(sprintf('%s1*',stimdir));


for i = 1:length(stimfiles)
    s=load(sprintf('%s%s', stimdir, stimfiles(i).name));
    e = getTaskParameters(s.myscreen, s.task{1});

    % discarding last trial if 
    if any(isnan(e.trials(end).volnum))
        clear tmp
        tmp=find(s.myscreen.events.volnum==e.trials(end).volnum(1)-1);
        s.myscreen.events.n=tmp(end);
    end
    e = getTaskParameters(s.myscreen, s.task{1});
    
        unattendedPairType = [];
        for p = 1:length(e.randVars.unattendedPair)
        if e.randVars.unattendedPair{p} == [1 2]
            unattendedPairType(p) = 1;
        elseif e.randVars.unattendedPair{p} == [3 4]
            unattendedPairType(p) = 2;
        end
        end
   
    stimonly1 = zeros(1,e.nTrials)-1;
    stimonly2 = zeros(1,e.nTrials)-1;
    stimonly3 = zeros(1,e.nTrials)-1;
    stimonly4 = zeros(1,e.nTrials)-1;
    % UNATTENDED SIDE
    % 1. Low contrast
    % 1-1) loc 1
%     [stimvol(1), stimNames(1), trialNum(1)] = getStimvolFromVarname('unattendedStim=-1 _x_ unattendedPairType=1 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    
    stimonly1(find(e.randVars.unattendedStim==-1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 1;
    stimonly1(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 2;
    stimonly1(find(e.randVars.unattendedStim==1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 3;
    stimonly1(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 4;
    
    stimonly2(find(e.randVars.unattendedStim==-1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 1;
    stimonly2(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 2;
    stimonly2(find(e.randVars.unattendedStim==1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 3;
    stimonly2(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 4;
    
    stimonly3(find(e.randVars.unattendedStim==-1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) =1;
    stimonly3(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) =2;
    stimonly3(find(e.randVars.unattendedStim==1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) =3;
    stimonly3(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) =4;
    
    stimonly4(find(e.randVars.unattendedStim==-1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) = 1;
    stimonly4(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) =2;
    stimonly4(find(e.randVars.unattendedStim==1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) =3;
    stimonly4(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) =4;
%     
%     unattended(find(e.randVars.unattendedStim==-1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 1;
%     unattended(find(e.randVars.unattendedStim==-1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 2;
%     unattended(find(e.randVars.unattendedStim==-1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) = 3;
%     unattended(find(e.randVars.unattendedStim==-1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) = 4;
%     
%     unattended(find(e.randVars.unattendedStim==1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 11;
%     unattended(find(e.randVars.unattendedStim==1 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 12;
%     unattended(find(e.randVars.unattendedStim==1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) = 13;
%     unattended(find(e.randVars.unattendedStim==1 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) = 14;
%     
%     unattended(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 1)) = 21;
%     unattended(find(e.randVars.unattendedStim==2 & unattendedPairType == 1 & e.randVars.unattendedStimPos == 2)) = 22;
%     unattended(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 1)) = 23;
%     unattended(find(e.randVars.unattendedStim==2 & unattendedPairType == 2 & e.randVars.unattendedStimPos == 2)) = 24;
% 
%     
%     attended(find(e.parameter.targetContrast == 1 & e.randVars.targetLoc ==1)) = 11;
%     attended(find(e.parameter.targetContrast == 1 & e.randVars.targetLoc ==2)) = 12;
%     attended(find(e.parameter.targetContrast == 1 & e.randVars.targetLoc ==3)) = 13;
%     attended(find(e.parameter.targetContrast == 1 & e.randVars.targetLoc ==4)) = 14;
%     
%     attended(find(e.parameter.targetContrast == 2 & e.randVars.targetLoc ==1)) = 21;
%     attended(find(e.parameter.targetContrast == 2 & e.randVars.targetLoc ==2)) = 22;
%     attended(find(e.parameter.targetContrast == 2 & e.randVars.targetLoc ==3)) = 23;
%     attended(find(e.parameter.targetContrast == 2 & e.randVars.targetLoc ==4)) = 24;
%     
%     addCalculatedVar('unattended',unattended, sprintf('%s%s', stimdir, stimfiles(i).name))
%         addCalculatedVar('attended',attended, sprintf('%s%s', stimdir, stimfiles(i).name))
 eval(sprintf('save %s -struct s',sprintf('%s%s', stimdir, stimfiles(i).name)));
    addCalculatedVar('stimonly1',stimonly1, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly2',stimonly2, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly3',stimonly3, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly4',stimonly4, sprintf('%s%s', stimdir, stimfiles(i).name))
     
%     stimFilename = sprintf('%s%s',stimdir,stimfiles(i).name(end-9:end));
%     save(stimFilename, 'stimvol','stimNames');
    
end
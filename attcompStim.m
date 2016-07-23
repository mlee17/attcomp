function attcompStim(session)
% creating stimvol files

% session = 's31620160720';
datadir = '~/data/attentionComp/';
stimdir = sprintf(['%s', session, '/Etc/'],datadir);
stimfiles = dir(sprintf('%s1*',stimdir));

for i = 1:length(stimfiles)
    load(sprintf('%s%s', stimdir, stimfiles(i).name));
    % e = getTaskParameters(myscreen,task);
    
    for p = 1:length(task{1}.randVars.unattendedPair)
        if task{1}.randVars.unattendedPair{p} == [1 2]
            task{1}.randVars.unattendedPairType(p) = 1;
        elseif task{1}.randVars.unattendedPair{p} == [3 4]
            task{1}.randVars.unattendedPairType(p) = 2;
        end
    end
    task{1}.randVars.originalName_{8} = 'task.randVars.calculated.unattendedPairType';
    task{1}.randVars.calculated.unattendedPairType = {nan};
    task{1}.randVars.names_{8} = 'unattendedPairType';
    task{1}.randVars.calculated_n_ = 5;
    task{1}.randVars.calculated_names_{5} = 'unattendedPairType'; 
    task{1}.randVars.varlen_(8) = length(task{1}.randVars.unattendedPairType);
    task{1}.randVars.n_ = 8;
    
    % UNATTENDED SIDE
    % 1. Low contrast
    % 1-1) loc 1
    [stimvol(1), stimNames(1), trialNum(1)] = getStimvolFromVarname('unattendedStim=-1 _x_ unattendedPairType=1 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
%    the same... [stimvol stimNames trialNum] = getStimvolFromVarname({'unattendedStim=-1','unattendedPairType=1','unattendedStimPos=1'}, myscreen,task,1,1,2);
    % 1-2) loc 2
    [stimvol(2), stimNames(2), trialNum(2)] = getStimvolFromVarname('unattendedStim=-1 _x_ unattendedPairType=1 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    % 1-3) loc 3
    [stimvol(3), stimNames(3), trialNum(3)] = getStimvolFromVarname('unattendedStim=-1 _x_ unattendedPairType=2 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    % 1-4) loc 4
    [stimvol(4), stimNames(4), trialNum(4)] = getStimvolFromVarname('unattendedStim=-1 _x_ unattendedPairType=2 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    
    % 2. High contrast
    % 2-1) loc 1
    [stimvol(5), stimNames(5), trialNum(5)] = getStimvolFromVarname('unattendedStim=1 _x_ unattendedPairType=1 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    % 2-2) loc 2
    [stimvol(6), stimNames(6), trialNum(6)] = getStimvolFromVarname('unattendedStim=1 _x_ unattendedPairType=1 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    % 2-3) loc 3
    [stimvol(7), stimNames(7), trialNum(7)] = getStimvolFromVarname('unattendedStim=1 _x_ unattendedPairType=2 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    % 2-4) loc 4
    [stimvol(8), stimNames(8), trialNum(8)] = getStimvolFromVarname('unattendedStim=1 _x_ unattendedPairType=2 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    
    % 3. Low & high together
    % 3-1) config 1
    [stimvol(9), stimNames(9), trialNum(9)] = getStimvolFromVarname('unattendedStim=2 _x_ unattendedPairType=1 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    % 3-2) config 2
    [stimvol(10), stimNames(10), trialNum(10)] = getStimvolFromVarname('unattendedStim=2 _x_ unattendedPairType=1 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    % 3-3) config 3
    [stimvol(11), stimNames(11), trialNum(11)] = getStimvolFromVarname('unattendedStim=2 _x_ unattendedPairType=2 _x_ unattendedStimPos=1', myscreen,task,1,1,2);
    % 3-4) config 4
    [stimvol(12), stimNames(12), trialNum(12)] = getStimvolFromVarname('unattendedStim=2 _x_ unattendedPairType=2 _x_ unattendedStimPos=2', myscreen,task,1,1,2);
    
    % ATTENDED SIDE
    % 1. Attend low
    % 1-1:4) loc 1-4
    [stimvol(13), stimNames(13), trialNum(13)] = getStimvolFromVarname('attendContrast=1 _x_ targetLoc=1', myscreen,task,1,1,2);
    [stimvol(14), stimNames(14), trialNum(14)] = getStimvolFromVarname('attendContrast=1 _x_ targetLoc=2', myscreen,task,1,1,2);
    [stimvol(15), stimNames(15), trialNum(15)] = getStimvolFromVarname('attendContrast=1 _x_ targetLoc=3', myscreen,task,1,1,2);
    [stimvol(16), stimNames(16), trialNum(16)] = getStimvolFromVarname('attendContrast=1 _x_ targetLoc=4', myscreen,task,1,1,2);

    % 2. Attend high
    % 2-1:4) loc 1-4
    [stimvol(17), stimNames(17), trialNum(17)] = getStimvolFromVarname('attendContrast=2 _x_ targetLoc=1', myscreen,task,1,1,2);
    [stimvol(18), stimNames(18), trialNum(18)] = getStimvolFromVarname('attendContrast=2 _x_ targetLoc=2', myscreen,task,1,1,2);
    [stimvol(19), stimNames(19), trialNum(19)] = getStimvolFromVarname('attendContrast=2 _x_ targetLoc=3', myscreen,task,1,1,2);
    [stimvol(20), stimNames(20), trialNum(20)] = getStimvolFromVarname('attendContrast=2 _x_ targetLoc=4', myscreen,task,1,1,2);    
    
    stimNames = {'UL1' 'UL2' 'UL3' 'UL4' 'UH1' 'UH2' 'UH3' 'UH4' 'UT1' 'UT2' 'UT3' 'UT4', ...
        'AL1' 'AL2' 'AL3' 'AL4' 'AH1' 'AH2' 'AH3' 'AH4'};
    
    stimFilename = sprintf('%s%s',stimdir,stimfiles(i).name(end-9:end));
    save(stimFilename, 'stimvol','stimNames');
    
end
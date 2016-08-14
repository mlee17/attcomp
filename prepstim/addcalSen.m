function addcalSen(session)

session = 's31620160808';
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
    
    stimonly1 = zeros(1,e.nTrials)-1;
    stimonly2 = zeros(1,e.nTrials)-1;
    stimonly3 = zeros(1,e.nTrials)-1;
    stimonly4 = zeros(1,e.nTrials)-1;
    %low alone/ low w high/ high alone/ high w low
    % pos 1
    stimonly1(find(e.randVars.unattendedStim==-1 & e.randVars.unattendedStimPos == 1)) = 1;
    stimonly1(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 1)) = 2;
    stimonly1(find(e.randVars.unattendedStim==1 & e.randVars.unattendedStimPos == 2)) = 3;
    stimonly1(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 2)) = 4;
    % pos 2
    stimonly2(find(e.randVars.unattendedStim==-1 & e.randVars.unattendedStimPos == 2)) = 1;
    stimonly2(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 2)) = 2;  
    stimonly2(find(e.randVars.unattendedStim==1 & e.randVars.unattendedStimPos == 1)) = 3;
    stimonly2(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 1)) = 4;
    
    % pos 3
    stimonly3(find(e.randVars.unattendedStim2==-1 & e.randVars.unattendedStimPos2 == 1)) = 1;
    stimonly3(find(e.randVars.unattendedStim2==2 & e.randVars.unattendedStimPos2 == 1)) = 2;
    stimonly3(find(e.randVars.unattendedStim2==1 & e.randVars.unattendedStimPos2 == 2)) = 3;
    stimonly3(find(e.randVars.unattendedStim2==2 & e.randVars.unattendedStimPos2 == 2)) = 4;
    % pos 4
    stimonly4(find(e.randVars.unattendedStim2==-1 & e.randVars.unattendedStimPos2 == 2)) = 1;
    stimonly4(find(e.randVars.unattendedStim2==2 & e.randVars.unattendedStimPos2 == 2)) = 2;  
    stimonly4(find(e.randVars.unattendedStim2==1 & e.randVars.unattendedStimPos2 == 1)) = 3;
    stimonly4(find(e.randVars.unattendedStim2==2 & e.randVars.unattendedStimPos2 == 1)) = 4;
    
    eval(sprintf('save %s -struct s',sprintf('%s%s', stimdir, stimfiles(i).name)));
    addCalculatedVar('stimonly1',stimonly1, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly2',stimonly2, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly3',stimonly3, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimonly4',stimonly4, sprintf('%s%s', stimdir, stimfiles(i).name))
end
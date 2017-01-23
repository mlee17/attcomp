function addcalLoc(session)

session = 's316combined';
datadir = '~/data/attentionComp/';
stimdir = sprintf(['%s', session, '/Etc/'],datadir);
stimfiles = dir(sprintf('%s1*',stimdir));

for i = 12:length(stimfiles)
    if any(strcmp(stimfiles(i).name, {'160720_stim04.mat', '160720_stim13.mat', '160720_stim14.mat', ...
            '160805_stim01.mat', '160805_stim11.mat'}))
        display('(addCalLoc) skipping localizer stim file')
        continue
    end
%     if strcmp(stimfiles(i).name(1:6), '160720')
%         continue
%     end

display(stimfiles(i).name)
    s=load(sprintf('%s%s', stimdir, stimfiles(i).name));
    e = getTaskParameters(s.myscreen, s.task{1});
    
    % discarding last trial if 
    if any(isnan(e.trials(end).volnum))
        clear tmp
        tmp=find(s.myscreen.events.volnum==e.trials(end).volnum(1)-1);
        s.myscreen.events.n=tmp(end);
    end
    e = getTaskParameters(s.myscreen, s.task{1});
    
    stimloc1 = zeros(1,e.nTrials)-1;
    stimloc2 = zeros(1,e.nTrials)-1;
    stimloc3 = zeros(1,e.nTrials)-1;
    stimloc4 = zeros(1,e.nTrials)-1;
    
    stimlocC1 = zeros(1,e.nTrials)-1;
    stimlocC2 = zeros(1,e.nTrials)-1;
    stimlocC3 = zeros(1,e.nTrials)-1;
    stimlocC4 = zeros(1,e.nTrials)-1;
    
    %for each location
    %High contrast / Low contrast/ High Neighbor / Low Neighbor / 
    %pos 1
    % stimonly1=3 stimonly1=1 stimonly2=3 stimonly2=1
    
    %low alone/ low w high/ high alone/ high w low
    
    
    % pos 1
    % loc1 high/ loc1 high/ loc2 high/ loc2 low / 
    % loc3 high/ loc3 low/ loc4 high/ loc4 low
    
    stimloc1(find(e.randVars.unattendedStim==1 & e.randVars.unattendedStimPos == 2)) = 1;
    stimloc1(find(e.randVars.unattendedStim==-1 & e.randVars.unattendedStimPos == 1)) = 2;
        
%     stimloc1(find(e.randVars.unattendedStim==-1 & e.randVars.unattendedStimPos == 1)) = 1;
%     stimloc1(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 1)) = 2;
%     stimloc1(find(e.randVars.unattendedStim==1 & e.randVars.unattendedStimPos == 2)) = 3;
%     stimloc1(find(e.randVars.unattendedStim==2 & e.randVars.unattendedStimPos == 2)) = 4;
    % pos 2
    stimloc2(find(e.randVars.unattendedStim==1 & e.randVars.unattendedStimPos == 1)) = 1;
    stimloc2(find(e.randVars.unattendedStim==-1 & e.randVars.unattendedStimPos == 2)) = 2;
        
    % pos 3
    stimloc3(find(e.randVars.unattendedStim2==1 & e.randVars.unattendedStimPos2 == 2)) = 1;
    stimloc3(find(e.randVars.unattendedStim2==-1 & e.randVars.unattendedStimPos2 == 1)) = 2;
    
    % pos 4
    stimloc4(find(e.randVars.unattendedStim2==1 & e.randVars.unattendedStimPos2 == 1)) = 1;
    stimloc4(find(e.randVars.unattendedStim2==-1 & e.randVars.unattendedStimPos2 == 2)) = 2;
    
    % pos 1
    % loc 3 high / loc3 low/ loc 4 high/ loc 4 low
    stimlocC1(find((stimloc2~=-1) & (stimloc3==1))) = 1;
    stimlocC1(find((stimloc2~=-1) & (stimloc3==2))) = 2;
    stimlocC1(find((stimloc2~=-1) & (stimloc4==1))) = 3;
    stimlocC1(find((stimloc2~=-1) & (stimloc4==2))) = 4;
    % pos2
    stimlocC2(find((stimloc1~=-1) & (stimloc3==1))) = 1;
    stimlocC2(find((stimloc1~=-1) & (stimloc3==2))) = 2;
    stimlocC2(find((stimloc1~=-1) & (stimloc4==1))) = 3;
    stimlocC2(find((stimloc1~=-1) & (stimloc4==2))) = 4;
    % pos3
    % loc 1 high/ loc 1 low/ loc4 high/ loc4 low
    stimlocC3(find((stimloc4~=-1) & (stimloc1==1))) = 1;
    stimlocC3(find((stimloc4~=-1) & (stimloc1==2))) = 2;
    stimlocC3(find((stimloc4~=-1) & (stimloc2==1))) = 3;
    stimlocC3(find((stimloc4~=-1) & (stimloc2==2))) = 4;
    % pos 4
    stimlocC4(find((stimloc3~=-1) & (stimloc1==1))) = 1;
    stimlocC4(find((stimloc3~=-1) & (stimloc1==2))) = 2;
    stimlocC4(find((stimloc3~=-1) & (stimloc2==1))) = 3;
    stimlocC4(find((stimloc3~=-1) & (stimloc2==2))) = 4;
    

    eval(sprintf('save %s -struct s',sprintf('%s%s', stimdir, stimfiles(i).name)));
    addCalculatedVar('stimloc1',stimloc1, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimloc2',stimloc2, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimloc3',stimloc3, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimloc4',stimloc4, sprintf('%s%s', stimdir, stimfiles(i).name))
    
    addCalculatedVar('stimlocC1',stimlocC1, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimlocC2',stimlocC2, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimlocC3',stimlocC3, sprintf('%s%s', stimdir, stimfiles(i).name))
    addCalculatedVar('stimlocC4',stimlocC4, sprintf('%s%s', stimdir, stimfiles(i).name))
end
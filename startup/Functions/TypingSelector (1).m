function TypingSelector
%%
% This is a master control program for unit typing in the CN, containing
% 4 sub-routines built separately by CW and ANH. The probability
% computation (1) is fully automatic, but does not provide judgement of
% unit-type and only gives you probability of based on published criteria.
% The PSTH typing program (2) is fully manual, through which the user
% judges the unit-type based on repeated plotting of PSTH. The
% semi-automatic program (3) was the earlier rendition built by CW but
% extensively used and imporved by ANH. ANH expanded capability for user
% input for accurate determination of receptive field info. This is then
% used in conjunction with the VCN typing program (4), credit to ANH, which
% provides an interactrive process for determine VCN units. Users may adopt
% either or all 4 to their liking. Results are saved in the parent folder
% instead of matlab workspace.
%
% CW -April 2018.
%
% This program requires other functions to operate properly. Please 
% add
% \\maize.umhsnas.med.umich.edu\\KHRI-SES-Lab\\Calvin\\Analysis\\functions
% and subfolders to matlab path.


%%
parent_folder_of_ssts = uigetdir


%%
TypeList={'Compute probability (auto)',...
    'View & type by PSTH (manual)',...
    'View & collect RF info (semi-auto)',...
    '+VCN typing (auto)'};
[sel,v] = listdlg('PromptString','Typing using...',...
    'SelectionMode','multiple',...
    'ListString',TypeList,'listsize',[200,200]);


sdir = fullfile(parent_folder_of_ssts,'typing_result');
if ~exist(sdir,'dir')
    mkdir(sdir);
    cp={};
else
    cp=what(sdir);
    cp=cp.mat;
end
fid = fopen(fullfile(sdir,'log.txt'),'a');
if fid==0
   error('Error opening log.txt'); 
end
fprintf(fid,'%s: Start %s',datestr(now),parent_folder_of_ssts);


%%
mats=what(parent_folder_of_ssts);
mats=mats.mat;
mats(strcmp(mats,'block_list.mat'))=[];
for c=1:length(mats)
    ll=load(fullfile(parent_folder_of_ssts,mats{c}));
        fprintf('Loading %s...\n',mats{c})
        fprintf(fid,'%s: Loading %s...\r\n',datestr(now),mats{c});    
    if length(ll.sst_sorted)>1
        sta=2;
    else
        sta=1;
    end
    for u=sta:length(ll.sst_sorted)
        sst=ll.sst_sorted(u);
        if iscell(sst)
           sst=sst{1}; 
        end
        %%
        fn = sprintf('unit_%d_%d.mat',sst.Channel,sst.Unit);
        cp=what(sdir);
        cp=cp.mat;
        if ~ismember(fn,cp)
            fprintf('Processing %s...\n',fn)
            fprintf(fid,'%s: Processing %s...\r\n',datestr(now),fn);
            OP=struct();
            if any(sel==1)
                [result bb F]=unitTypingAuto(sst);
                if ~isempty(result)
                    OP=table2struct(result);
                    OP.tracedRF=bb;
                end
            end
            if any(sel==2)
                fprintf('Waiting for user input (2)...\n')
                fprintf(fid,'%s: Waiting for user input for (2)...\r\n',datestr(now));
                [unittype,bfH,thrH] = unitTypingGUI(sst);
                OP.id_psth=unittype;
                OP.id_bf=bfH;
                OP.id_thr=thrH;     
            end
            
            if any(sel==3)&~any(sel==4)
                fprintf('Waiting for user input (3)...\n')
                fprintf(fid,'%s: Waiting for user input for (3)...\r\n',datestr(now));
                [bfH2,thrH2,monotonicity,~,q10,~,~,~,q40]=unitTypingANH(sst);
                OP.id2_bf=bfH2;
                OP.id2_thr=thrH2;
                OP.monotonicity=monotonicity;
                OP.q10=q10;
                OP.q40=q40;
            end
            
            if any(sel==4)
                fprintf('Waiting for user input (4)...\n')
                fprintf(fid,'%s: Waiting for user input for (4)...\r\n',datestr(now));
                [UnitType,bfH2,thrH2,q10,q40,monotonicity,p20,sus20,fsl20,CV20,p50,sus50,fsl50,CV50]=unitTypingVCN(sst);
                    OP.id2_bf=bfH2;
                    OP.id2_thr=thrH2;
                    OP.monotonicity=monotonicity;
                    OP.q10=q10;
                    OP.q40=q40;
                OP.id2_psth=UnitType;
                OP.p_sus_fsl_cv20=[p20,sus20,fsl20,CV20];
                OP.p_sus_fsl_cv50=[p50,sus50,fsl50,CV50];
            end    
            
            output=OP;
            save(fullfile(parent_folder_of_ssts,'typing_result',fn),'output')
            fprintf('Saved.\n\n')
            fprintf(fid,'%s: Saved.\r\n\n',datestr(now));
            close all
        end
        
    end
end


fclose(fid);

end
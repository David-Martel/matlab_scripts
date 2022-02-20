function getoffthecarandwalk
%%

parent_folder_of_ssts = uigetdir;
mats=what(parent_folder_of_ssts);
mats=mats.mat;
mats(strcmp(mats,'block_list.mat'))=[];
warning('off','all')
fprintf('** Do not open excel while this function is in operation **\n')

for c=1:length(mats)
    ll=load(fullfile(parent_folder_of_ssts,mats{c}));
    for u=1:length(ll.sst_sorted)
        sst=ll.sst_sorted{u};
        fn=fullfile(parent_folder_of_ssts,'xls',sprintf('%s_%d.xlsx',mats{c}(1:end-4),u-1));
        if ~exist(fullfile(parent_folder_of_ssts,'xls'))
            mkdir(fullfile(parent_folder_of_ssts,'xls'))
        end        
        %%
        N=fieldnames(sst.Epocs);
        for i=1:length(N)
            T=dataset2table(sst.Epocs.(N{i}));
            writetable(T,fn,'sheet',N{i},'writerownames',1)
        end
        T=dataset2table(sst.Spikes);
        %%
        [U,~,b]=unique(sst.Spikes.TrialIdx);
        infoarray = NaN(length(b),size(sst.Epocs.Values,2));
        for i=1:max(b)
            tt=U(i);
            infoarray(b==i,:)=repmat(double(sst.Epocs.Values(tt,:)),sum(b==i),1);
        end
        T=[dataset2table(sst.Spikes),...
            array2table(infoarray,'variablenames',sst.Epocs.Values.Properties.VarNames)];

        %%
        
        writetable(T,fn,'sheet','Spikes')
        %%
        if exist(fn)
            objExcel = actxserver('Excel.Application');
            objExcel.Workbooks.Open(fn); % Full path is necessary!
            % Delete sheets.
            try
                % Throws an error if the sheets do not exist.
                objExcel.ActiveWorkbook.Worksheets.Item(['Sheet' '1']).Delete;
                objExcel.ActiveWorkbook.Worksheets.Item(['Sheet' '2']).Delete;
                objExcel.ActiveWorkbook.Worksheets.Item(['Sheet' '3']).Delete;
            end
            % Save, close and clean up.
            objExcel.ActiveWorkbook.Save;
            objExcel.ActiveWorkbook.Close;
            objExcel.Quit;
            objExcel.delete;
        end
        %%
        fprintf('%s: unit %d of %d\n',mats{c}(1:end-4),u-1,length(ll.sst_sorted)-1)
    end
end


fprintf('All done.\n')
end
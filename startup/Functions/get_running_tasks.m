function task_data = get_running_tasks(varargin)

p = inputParser;

addOptional(p,'processrun','');

parse(p,varargin{:})

if ~isempty(p.Results.processrun)
    filter_str = sprintf('/fi "IMAGENAME eq %s"',p.Results.processrun);
else
    filter_str = '';
end

cmd_list = {'tasklist',filter_str};
[status,response] = system(strjoin(cmd_list,' '));


if ~status

    if ~contains(response,'No tasks are running')


        response(1) = ''; response(end) = '';
        task_data = struct;
        process_data = strsplit(response,newline);
        process_data(contains(process_data,'=')) = [];
        base_grp = regexp(process_data{1},'[ ]{2,}','split');
        for iter = 1:numel(process_data)

            proc_parts = regexp(process_data{iter},'[ ]{2,}','split');
                
            task_data(iter).Image = proc_parts{contains(base_grp,'Image Name')};
            task_data(iter).PID = proc_parts{contains(base_grp,'PID Session Name')};
            task_data(iter).Session = proc_parts{contains(base_grp,'Session#')};
            task_data(iter).MemUse = proc_parts{contains(base_grp,'Mem Usage')};

            if iter == 1         
                task_data = repmat(task_data,1,numel(process_data)-1);
            end
        end
    else
        task_data = struct;
    end

else
    task_data = struct;
end













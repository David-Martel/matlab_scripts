function [slow_trials, normal_trials, fast_trials] = test_prioritization_speed(counts,matrix_size)

test_matrix = zeros(matrix_size);

trial_count = counts;
start_time = 0;
stop_time = 0;


slow_trials = zeros(1,trial_count);
normal_trials = zeros(1,trial_count);
fast_trials = zeros(1,trial_count);

%run normal priority
priority('n');
for idx = 1:trial_count
    start_time = tic;
    test_matrix = magic(matrix_size);
    test_matrix = test_matrix^2;
    normal_trials(idx) = toc(start_time);
end

priority('h');
for idx = 1:trial_count
    start_time = tic;
    test_matrix = magic(matrix_size);
    test_matrix = test_matrix^2;
    fast_trials(idx) = toc(start_time);
end

priority('l');
for idx = 1:trial_count
    start_time = tic;
    test_matrix = magic(matrix_size);
    test_matrix = test_matrix^2;
    slow_trials(idx) = toc(start_time);
end

priority('n');
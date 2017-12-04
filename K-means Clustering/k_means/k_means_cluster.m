function [] = k_means_cluster( varargin )

    data = load(varargin{1});
    data(:, end) = [];
    K = str2num(varargin{2});
    it = str2num(varargin{3});
    N = size(data, 1);
    D = size(data, 2);
    
    label = randi([1 K],1,N)';
    mn = zeros(K, D);
  
    for i = 1: (it+1)
        error = 0;
        for j = 1: K
            cluster = data(j==label(:, 1), :);
            mn(j, :) = mean(cluster);
            error = error + sum(sqrt(sum((cluster(:,:)- mn(j,:)).^2, 2)));
        end
        for j = 1: N
            d = zeros(K,1);
            for k = 1: K
                d(k,1) = sqrt(sum((data(j,:)- mn(k,:)).^2, 2));
            end
            [M, I] = min(d);
            label(j, 1) = I;
        end
        if (i== 1)
            fprintf('After initialization: error = %.4f\n', error);
        else
            fprintf('After iteration %d: error = %.4f\n', i-1, error);
        end
    end
end


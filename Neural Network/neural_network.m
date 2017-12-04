function [] = neural_network(varargin)

    trainingData = load(varargin{1});
    testData = load(varargin{2});
    classes = unique(trainingData(:,end));
    
    L = str2num(varargin{3}); %layers
    U = str2num(varargin{4}); %units per layer
    R = str2num(varargin{5}); %rounds
    N = size(trainingData, 1);
    D = size(trainingData, 2)-1;

    maxDim = max(size(classes, 1)+1, max(D+1, U+1));
    
    z = zeros(maxDim, L);
    w = zeros(maxDim, maxDim, L);
    
    delta = zeros(maxDim, L);
    
    maxElement = max(max(trainingData(: , [1 D])));
        
    %%%%%%%%%%%%%%%%%%%%%%% training %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for l = 2: L
        for ii = 2: maxDim
            for i = 1: maxDim
                w(ii, i, l) = 0.1 * rand - 0.05;
            end
        end
    end
    
    lr = 1;
    for r = 1: R
        for n = 1: N
            %initialize input layer%
            z(1, 1) = 1;
            for j = 2: (D+1)
                z(j, 1) = trainingData(n, j-1)/maxElement;
            end
            %compute outputs%
            for l = 2: L
                z(1, l) = 1;
                
                if l == L
                    np1 = size(classes, 1) + 1;
                else
                    np1 = U+1;
                end
                
                for j = 2: np1
                    if l == 2
                        np2 = D+1;
                    else
                        np2 = U+1;
                    end
                    
                    a = 0;
                    for i = 1: np2
                        a = a + z(i, l-1) * w(j, i, l);
                    end
                    z(j, l) = logsig(a);
                end
            end
            %update weights in output layer%
            for j = 2: size(classes, 1)+1
                if trainingData(n, end) == classes(j-1)
                    delta(j, L) = z(j, L) - 1;
                else
                    delta(j, L) = z(j, L);
                end
                delta(j, L) = delta(j, L) * z(j, L) * (1-z(j, L));
                if L == 2
                    np = D+1;
                else
                    np = U+1;
                end
                for i = 1: np
                    w(j, i, l) = w(j, i, l) - lr * delta(j, L) * z(i, L-1);
                end
            end
            %update weights in hidden layers%

            for l = (L-1): -1: 2
                for j = 1: (U+1)
                    if l == (L-1)
                        np = size(classes, 1) + 1;
                    else
                        np = U+1;
                    end
                    for u = 2: np
                        delta(j, l) = delta(j, l) + delta(u, l+1) * w(u, j, l+1);
                    end
                    
                    delta(j, l) = delta(j, l) * z(j, l) * (1-z(j, l));
                    if l == 2
                        np = D+1;
                    else
                        np = U+1;
                    end
                    for i = 1: np
                        w(j, i, l) = w(j, i, l) - lr * delta(j, l) * z(i, l-1);
                    end
                end
            end
        end
        lr = lr * 0.98;
    end
    
    %disp(w);
   
    %%%%%%%%%%%%%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for n = 1: size(testData, 1)
        %initialize input layer%
        z(1, 1) = 1;
        for j = 2: (D+1)
            z(j, 1) = testData(n, j-1)/maxElement;
        end
        %compute outputs%
        for l = 2: L
            z(1, l) = 1;

            if l == L
                np1 = size(classes, 1) + 1;
            else
                np1 = U+1;
            end

            for j = 2: np1
                if l == 2
                    np2 = D+1;
                else
                    np2 = U+1;
                end

                a = 0;
                for i = 1: np2
                    a = a + z(i, l-1) * w(j, i, l);
                end
                z(j, l) = logsig(a);
            end
        end
        %assign class%
        mx = -Inf;
        for j = 2: size(classes, 1) + 1
            mx = max(mx, z(j, L));
        end
        idx = 0;
        found = 0;
        maxCount = 0;
        for j = 2: size(classes, 1) + 1
            if z(j, L) == mx
                if classes(j-1) == testData(n, end)
                    found = 1;
                end
                maxCount = maxCount + 1;
                idx = j;
            end
        end
        
        accuracy(n) = found/maxCount;
     
        fprintf('ID=%5d, predicted=%3d, true=%3d, accuracy=%4.2f\n', n-1, classes(idx-1), testData(n, end), accuracy(n));
    end
    fprintf('classification accuracy=%6.4f\n', mean(accuracy));
end


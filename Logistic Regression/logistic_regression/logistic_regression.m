function [] = logistic_regression( varargin )

    trainingData = load(varargin{1});
    
    degree = str2num(varargin{2});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    D = size(trainingData, 2) - 1;
    w = zeros(degree*D + 1, 1);
    N  = size(trainingData, 1);
    phi = zeros(N, degree * D);
    
    for i = 1: N
        phi(i, 1) = 1;
        for j = 1: size(trainingData, 2) - 1;
            if degree == 1
                phi(i, j+1) = trainingData(i, j);
            else
                phi(i, 2*j) = trainingData(i, j);
                phi(i, 2*j + 1) = trainingData(i, j)^2;
            end
        end
    end
    
    t = trainingData(:, size(trainingData,2));
    for i = 1: size(t, 1)
        if t(i, 1) ~= 1
            t(i, 1) = 0;
        end
    end
  
    f = 1;
    e = zeros(degree * D + 1, 1);
    while 1
        y = logsig(phi*w);
        R = zeros(N, N);
        for i = 1: N
            R(i, i) = y(i, 1)*(1-y(i, 1));
        end
        
        tempe = transpose(phi)*(y-t);
        if (f == 0 & abs(e - tempe) < 0.001)
            break
        end
        tempw = w - inv(transpose(phi)*R*phi)*tempe;
        if (sumabs(tempw - w) < 0.001)
            break
        end
        w = tempw;
        e = tempe;
        f = 0;
    end
    
    for i = 1: size(w, 1)
        fprintf('w%d=%.4f\n', i-1, w(i, 1));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    testData = load(varargin{3});
    
    for i = 1: size(testData, 1)
        test_phi(i, 1) = 1;
        for j = 1: size(testData, 2) - 1;
            if degree == 1
                test_phi(i, j+1) = testData(i, j);
            else
                test_phi(i, 2*j) = testData(i, j);
                test_phi(i, 2*j + 1) = testData(i, j)^2;
            end
        end
    end
    
    y_test = logsig(test_phi*w);
    
    for i = 1: size(y_test, 1)    
        if abs(y_test(i, 1) - 0.5) < 0.00001
            accuracy(i) = 0.5;
            p = y_test(i, 1);
            predicted_class = 1;
        elseif ((y_test(i, 1) > 0.5 && testData(i, D+1) == 1) || (y_test(i, 1) < 0.5 && testData(i, D+1) ~= 1)) 
            accuracy(i) = 1;
            if testData(i, D+1) == 1
                p = y_test(i, 1);
                predicted_class = 1;
            else
                p = 1 - y_test(i, 1);
                predicted_class = 0;
            end
        else
            accuracy(i) = 0;
            if testData(i, D+1) == 1
                p = 1 - y_test(i, 1);
                predicted_class = 0;
            else
                p = y_test(i, 1);
                predicted_class = 1;
            end
        end
        
        if testData(i, D+1) == 1
            true_class = 1;
        else 
            true_class = 0;
        end
        fprintf('ID=%5d, predicted=%3d, probability = %.4f, true=%3d, accuracy=%4.2f\n', i - 1, predicted_class, p, true_class, accuracy(i));
    end
   
    fprintf('classification accuracy=%6.4f\n', mean(accuracy));
end


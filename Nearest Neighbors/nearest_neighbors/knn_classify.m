function [] = knn_classify( varargin )

    trainingData = load(varargin{1});
    testData = load(varargin{2});
    K = str2num(varargin{3});
    N = size(trainingData,1);
    D = size(trainingData, 2) - 1;    
    s = zeros(D);
    m = zeros(D);

    for j = 1: D
        s(j) = std(trainingData(1:N, j), 1);
        m(j) = mean(trainingData(1:N, j));
        for i = 1: N
            trainingData(i, j) = (trainingData(i, j) - m(j))/s(j);
        end
        for i = 1: size(testData, 1)
            testData(i, j) = (testData(i, j) - m(j))/s(j);
        end
    end
    distances = zeros(N,2);
    total_accuracy = 0;
    for i = 1: size(testData,1)
        distances(:,1) = sum((trainingData(:, 1:(end-1))-testData(i, 1:(end-1))).^2, 2);
        distances(:,2) = trainingData(:, end);
        distances = sortrows(distances);
        prediction = mode(distances(1:K, 2));
        if(prediction == testData(i, end))
            accuracy = 1;
        else
            accuracy = 0;
        end
        total_accuracy = total_accuracy + accuracy;
        fprintf('ID=%5d, predicted=%3d, true=%3d, accuracy=%4.2f\n', i-1, prediction, testData(i, end), accuracy);
    end
    fprintf('classification accuracy=%6.4f\n', total_accuracy/size(testData, 1));
end


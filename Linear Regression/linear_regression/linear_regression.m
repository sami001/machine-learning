function [] = linear_regression(varargin)
    data = load(varargin{1});
    x = data(:,1);
    t = data(:,2);
    
    M = str2num(varargin{2}) + 1;
    lambda = str2num(varargin{3});
    
    for i = 1: size(x, 1)
        for j = 1: M
            phi(i, j) = (x(i ,1))^(j-1);
        end
    end

    w = pinv(eye(M)*lambda + transpose(phi)*phi)*transpose(phi)*t;
    
    w0 = w(1);
    w1 = w(2);
    
    if M == 2
        w2 = 0;
    else 
        w2 = w(3);
    end
        
    fprintf('w0=%.4f\n', w0);
    fprintf('w1=%.4f\n', w1);
    fprintf('w2=%.4f\n', w2);

end


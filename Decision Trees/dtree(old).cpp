#include <cstdio>
#include <cstring>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <string>
#include <iostream>
#include <sstream>
#include <vector>
#include <algorithm>
using namespace std;

#define sqr(x) ((x) * (x))
#define INF 1000000000

double toInt(string s){double r = 0;istringstream sin(s);sin >> r; return r;}

vector<double>matrix[1000000];
vector<int>classes;
int N, maxNode = -INF;
int pruning_thr;
double cnt[100],cntl[100], cntr[100];
bool vis[1000000];

struct nodeInfo {
    int attribute;
    double threshold, gain;
    vector<double>cls;
};

nodeInfo tree[1000000];

double LOG2(double k1, int k2) {
    if(k1 == 0) return 0;
    return log2(k1/k2);
}

double informationGain(vector<int>examples, int attribute, double threshold)
{
    memset(cnt, 0, sizeof(cnt));
    memset(cntl, 0, sizeof(cntl));
    memset(cntr, 0, sizeof(cntr));
    vector<int>examples_left, examples_right;
    double ans = 0, ans1 = 0, ans2 = 0;
    for(int i = 0; i < examples.size(); i++) {
        cnt[(int)matrix[examples[i]][matrix[0].size() - 1]]++;
        if(matrix[examples[i]][attribute] < threshold) {
            examples_left.push_back(examples[i]);
            cntl[(int)matrix[examples[i]][matrix[0].size() - 1]]++;
        }
        else {
            examples_right.push_back(examples[i]);
            cntr[(int)matrix[examples[i]][matrix[0].size() - 1]]++;
        }
    }
    for(int i = 0; i < classes.size(); i++) {
        ans  += (- (cnt[classes[i]]/examples.size()) * LOG2(cnt[classes[i]], examples.size()));
        ans1 += (- (cntl[classes[i]]/examples_left.size()) * LOG2(cntl[classes[i]], examples_left.size()));
        ans2 += (- (cntr[classes[i]]/examples_right.size()) * LOG2(cntr[classes[i]], examples_right.size()));
    }
   // cout <<ans <<' '<<ans1<< ' '<<ans2<<endl;
    return (ans - ((double)examples_left.size()/examples.size())*ans1 - ((double)examples_right.size()/examples.size())*ans2);
}

nodeInfo choose_attribute(vector<int>examples)
{
    nodeInfo best;
    double max_gain = -1;
    best.attribute = -1, best.threshold = -1;

    for(int i = 0; i < matrix[0].size() - 1; i++) {
        double L = INF, M = -INF;
        for(int j = 0; j < examples.size(); j++) {
            L = min(L, matrix[examples[j]][i]);
            M = max(M, matrix[examples[j]][i]);
        }
        for(int k = 1; k <= 50; k++) {
            double threshold = L + k*(M-L)/51;
            double gain = informationGain(examples, i, threshold);

            if(gain > max_gain) {
                max_gain = gain;
                best.attribute = i;
                best.threshold = threshold;
                best.gain = gain;
            }
        }
    }
    return best;
}

void DTL(vector<int>examples, int node, vector<double>def)
{
    maxNode = max(maxNode, node);
    int sameClass = matrix[examples[0]][matrix[0].size()-1];
    for(int i = 1; i < examples.size(); i++) {
        if(matrix[examples[i]][matrix[0].size()-1] != sameClass) {
            sameClass = -1;
            break;
        }
    }

    //cout << ' ' << node <<' '<< examples.size()<<endl;
    if(examples.size() < pruning_thr) {
        tree[node].attribute = -1;
        tree[node].cls = def;
        return;
    } else if(sameClass != -1) {
        vector<double>cls;
        for(int i = 0; i < classes.size(); i++) {
            if(classes[i] == sameClass) cls.push_back(1.0);
            else cls.push_back(0.0);
        }
        tree[node].attribute = -1;
        tree[node].cls = cls;
        return;
    }
    else {
        vis[node] = 1;
        nodeInfo best = choose_attribute(examples);
        tree[node].threshold = best.threshold;
        tree[node].attribute = best.attribute;
        tree[node].gain      = best.gain;

      //  cout << tree[node].threshold << endl;
        vector<int>examples_left, examples_right;
        for(int i = 0; i < examples.size(); i++) {
            if(matrix[examples[i]][best.attribute] < best.threshold) examples_left.push_back(examples[i]);
            else examples_right.push_back(examples[i]);
        }

        memset(cnt, 0, sizeof(cnt));

        for(int i = 0; i < examples.size(); i++) {
            cnt[(int)matrix[examples[i]][matrix[0].size() - 1]]++;
        }
        vector<double>distribution;
        for(int i = 0; i < classes.size(); i++) {
            distribution.push_back(cnt[classes[i]]/examples.size());
        }

        DTL(examples_left, 2*node, distribution);
        DTL(examples_right, 2*node + 1, distribution);
    }
}

int main()
{
    /***********training *************/
    N = 0;
    pruning_thr = 50;
    freopen("pendigits_training.txt", "r", stdin);
    //freopen("o.txt", "w", stdout);

    string line;
    while(getline(cin, line)) {
        string temp;
        for(int i = 0; i < line.length(); i++) {
            if(line[i] != ' ') temp += line[i];
            else if(temp.length()) {
                matrix[N].push_back(toInt(temp));
                temp = "";
            }
        }
        matrix[N].push_back(toInt(temp));
        classes.push_back(matrix[N].back());
        N++;
    }

    sort(classes.begin(), classes.end());
    unique(classes.begin(), classes.end());
    for(int i = 0; i < classes.size() - 1; i++) {
        if(classes[i] > classes[i+1]) {
            classes.resize(i+1);
            break;
        }
    }

    vector<int>examples;
    for(int i = 0; i < N; i++) examples.push_back(i);

    memset(cnt, 0, sizeof(cnt));

    for(int i = 0; i < examples.size(); i++) {
        cnt[(int)matrix[examples[i]][matrix[0].size() - 1]]++;
    }

    vector<double>distribution;
    for(int i = 0; i < classes.size(); i++) {
        distribution.push_back(cnt[classes[i]]/examples.size());
    }

   // for(int i = 0; i < distribution.size(); i++) cout << distribution[i] << endl;


    DTL(examples, 1, distribution);

    for(int i = 1; i <= maxNode; i++) {
        if(vis[i]) {
            printf("tree=%2d, node=%3d, feature=%2d, thr=%6.2lf, gain=%lf\n",
                   1, i, tree[i].attribute, tree[i].threshold, tree[i].gain);
        }
    }

    /***********testing *************/
/*
    vector<double>testObject;


    freopen("pendigits_test.txt", "r", stdin);

    while(getline(cin, line)) {
        string temp;
        for(int i = 0; i < line.length(); i++) {
            if(line[i] != ' ') temp += line[i];
            else if(temp.length()) {
                testObject.push_back(toInt(temp));
                temp = "";
            }
        }
        testObject.push_back(toInt(temp));
    }

\

    return 0;
}

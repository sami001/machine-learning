#include <cstdio>
#include <cstring>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <string>
#include <fstream>
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
char method[20];
int N, maxNode;
int pruning_thr, nTree;
double classProb[100];
double cnt[100],cntl[100], cntr[100];
bool vis[1000000];

struct nodeInfo {
    int attribute;
    double threshold, gain;
    vector<double>cls;
};

nodeInfo tree[20][1000000];

void fileToMatrix(char* filename)
{
    for(int i = 0; i < N; i++) matrix[i].clear();
    N = 0;
    ifstream myfile (filename);
    string line;
    while(getline(myfile, line)) {
        string temp;
        for(int i = 0; i < line.length(); i++) {
            if(line[i] != ' ') temp += line[i];
            else if(temp.length()) {
                matrix[N].push_back(toInt(temp));
                temp = "";
            }
        }
        matrix[N].push_back(toInt(temp));
        N++;
    }
}

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
        if(examples_left.size()) ans1 += (- (cntl[classes[i]]/examples_left.size()) * LOG2(cntl[classes[i]], examples_left.size()));
        if(examples_right.size()) ans2 += (- (cntr[classes[i]]/examples_right.size()) * LOG2(cntr[classes[i]], examples_right.size()));
    }
    return (ans - ((double)examples_left.size()/examples.size())*ans1 - ((double)examples_right.size()/examples.size())*ans2);
}

nodeInfo choose_attribute(vector<int>examples)
{
    nodeInfo best;
    best.gain = -1, best.attribute = -1, best.threshold = -1;

    for(int i = 0; i < matrix[0].size() - 1; i++) {
        int A;
        if(!strcmp(method, "optimized")) {
            A = i;
        }
        else {
            if(i == 1) break;
            A = rand()%(matrix[0].size()-1);
        }
        double L = INF, M = -INF;
        for(int j = 0; j < examples.size(); j++) {
            L = min(L, matrix[examples[j]][A]);
            M = max(M, matrix[examples[j]][A]);
        }
        for(int k = 1; k <= 50; k++) {
            double threshold = L + k*(M-L)/51;
            double gain = informationGain(examples, A, threshold);

            if(gain > best.gain) {
                best.attribute = A;
                best.threshold = threshold;
                best.gain = gain;
            }
        }
    }
    return best;
}

void DTL(int t, vector<int>examples, int node, vector<double>def)
{
    maxNode = max(maxNode, node);

    if(examples.size() < pruning_thr) {
        tree[t][node].attribute = -1;
        tree[t][node].cls = def;
        return;
    }

    int sameClass = matrix[examples[0]][matrix[0].size()-1];
    for(int i = 1; i < examples.size(); i++) {
        if(matrix[examples[i]][matrix[0].size()-1] != sameClass) {
            sameClass = -1;
            break;
        }
    }

    if(sameClass != -1) {
        vector<double>cls;
        for(int i = 0; i < classes.size(); i++) {
            if(classes[i] == sameClass) cls.push_back(1.0);
            else cls.push_back(0.0);
        }
        tree[t][node].attribute = -1;
        tree[t][node].cls = cls;
        return;
    }
    else {
        vis[node] = 1;
        nodeInfo best = choose_attribute(examples);
        tree[t][node].threshold = best.threshold;
        tree[t][node].attribute = best.attribute;
        tree[t][node].gain      = best.gain;

        vector<int>examples_left, examples_right;
        for(int i = 0; i < examples.size(); i++) {
            if(matrix[examples[i]][best.attribute] < best.threshold) 
                examples_left.push_back(examples[i]);
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

        DTL(t, examples_left, 2*node, distribution);
        DTL(t, examples_right, 2*node + 1, distribution);
    }
}

void training(char* fileName)
{
    fileToMatrix(fileName);

    for(int i = 0; i < N; i++) {
        classes.push_back(matrix[i].back());
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

    if(!strcmp(method, "forest3")) nTree = 3;
    else if (!strcmp(method, "forest15")) nTree = 15;
    else nTree = 1;

    for(int t = 0; t < nTree; t++) {
        maxNode = -1;
        memset(vis, 0, sizeof(vis));
        DTL(t, examples, 1, distribution);

        for(int i = 1; i <= maxNode; i++) {
            if(vis[i]) {
                printf("tree=%2d, node=%3d, feature=%2d, thr=%6.2lf, gain=%lf\n",
                       t, i, tree[t][i].attribute, tree[t][i].threshold, tree[t][i].gain);
            }
        }
    }
}

void testing(char* fileName)
{
    fileToMatrix(fileName);

    double accuracy = 0;

    for(int i = 0; i < N; i++) {
        memset(classProb, 0, sizeof(classProb));
        for(int t = 0; t < nTree; t++) {
            int node = 1;
            while(tree[t][node].attribute != -1) {
                if(matrix[i][tree[t][node].attribute] < tree[t][node].threshold) node = 2*node;
                else node = 2*node + 1;
            }

            for(int j = 0; j < classes.size(); j++){
                    classProb[j] += tree[t][node].cls[j];
            }
        }

        for(int j = 0; j < classes.size(); j++) classProb[j] /= nTree;

        double mx = -INF;
        for(int j = 0; j < classes.size(); j++) {
            mx = max(mx, classProb[j]);
        }

        int idx = 0;
        double found = 0;
        int maxCount = 0;
        for(int j = 0; j < classes.size(); j++) {
            if (classProb[j] == mx) {
                if (classes[j] == (int)matrix[i][matrix[0].size()-1]) found = 1;
                maxCount++;
                idx = j;
            }
        }

        accuracy += (found/maxCount);

        printf("ID=%5d, predicted=%3d, true=%3d, accuracy=%4.2lf\n",
               i, classes[idx], (int)matrix[i][matrix[0].size()-1], found/maxCount);
    }

    printf("classification accuracy=%6.4lf\n", accuracy/N);

}

int main(int argc, char* argv[])
{
    strcpy(method, argv[3]);
    pruning_thr = atoi(argv[4]);
    srand (time(NULL));

    training(argv[1]);
    testing(argv[2]);

    return 0;
}

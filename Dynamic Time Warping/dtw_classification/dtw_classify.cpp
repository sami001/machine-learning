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
#define INF 10000000

struct points {
    double x, y;
};

struct objects {
    int cls;
    vector<points>ps;
};

double toInt(string s){double r = 0;istringstream sin(s);sin >> r; return r;}

vector < objects > trainingData;
vector < objects > testData;

double c[200][200];
double d[2500];

vector< objects > fileToData(char* filename)
{
    int k = 0;
    vector < objects > vv;

    objects obj;
    points p;

    ifstream myfile (filename);
    string line;

    while(getline(myfile, line)) {
        k++;

        if(line[0] == '-') {
            if(!obj.ps.empty()) vv.push_back(obj);
            obj.ps.clear();

            k = 0;
            continue;
        }
        if(k==2) {
            string temp;
            for(int i = 12; i < line.length(); i++) {
                temp += line[i];
            }
            obj.cls = (int)toInt(temp);
        }

        else if(k>5) {
            string temp;
            for(int i = 0; i < line.length(); i++) {
                if(line[i] != ' ') temp += line[i];
                else if(temp.length()) {
                    p.x = toInt(temp);
                    temp = "";
                }
            }
            p.y = toInt(temp);
            obj.ps.push_back(p);
        }
    }
    vv.push_back(obj);
    return vv;
}

double cost(points a, points b)
{
    return sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y));
}

double DTW(vector<points>X, vector<points>Y)
{
    c[0][0] = cost(X[0], Y[0]);
    int M = X.size();
    int N = Y.size();
    for(int i = 1; i < M; i++) c[i][0] = c[i-1][0] + cost(X[i], Y[0]);
    for(int i = 1; i < N; i++) c[0][i] = c[0][i-1] + cost(X[0], Y[i]);

    for(int i = 1; i < M; i++) {
        for(int j = 1; j < N; j++) {
            c[i][j] = min(c[i-1][j], min(c[i][j-1], c[i-1][j-1])) + cost(X[i], Y[j]);
        }
    }
    return c[M-1][N-1];
}

int main(int argc, char* argv[])
{
    trainingData = fileToData(argv[1]);
    testData = fileToData(argv[2]);

    double total_accuracy = 0;

    for(int i = 0; i < testData.size(); i++) {
        double minDist = INF, accuracy;
        int predictedClass;
        for(int j = 0; j < trainingData.size(); j++) {
            d[j] = DTW(testData[i].ps, trainingData[j].ps);
            minDist = min(minDist, d[j]);
        }
        double trueFound = 0, cnt = 0;
        for(int j = 0; j < trainingData.size(); j++) {
            if(d[j] == minDist) {
                cnt++;
                predictedClass = trainingData[j].cls;
                if(testData[i].cls == trainingData[j].cls)
                    trueFound = 1;
            }
        }

        accuracy = trueFound/cnt;
        total_accuracy += accuracy;
        printf("ID=%5d, predicted=%3d, true=%3d, accuracy=%4.2lf, distance = %.2lf\n", i+1, predictedClass, testData[i].cls, accuracy, minDist);
    }

    printf("classification accuracy=%6.4lf\n", total_accuracy/testData.size());

    return 0;
}
